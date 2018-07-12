function [obj] = run_MO_bayesian(obj, initialX, continueBool)
%RUN_MO_BAYESIAN Runs a multi-objective Bayesian optimization
%   INITIALX:	Row-wise set of X vectors to use as the initial Database.
%
%	CONTINUEBOOL:	Indicates if the run is a continuation of a previous
%					run, which could be incomplete.
%
%	Part of the MOSAO class. Private method.


% If no previous run data exists, cannot continue from past run
if isempty(obj.iter)
	continueBool = false;
end

% Set up parallel pool if needed
if obj.opt.BayesParallelMS
	poolObj = parpool('local', 'IdleTimeout', Inf);
	%pctrunonall(warning('OFF', 'MATLAB:nearlySingularMatrix')); % turns off singularity warnings
	finishUp = onCleanup(@() delete(poolObj)); % Ensure shutdown on cleanup
end

% Define options struct for fmincon and multistart
obj.fminconOptions = optimoptions( ...
	'fmincon', ...
	'Algorithm', 'interior-point', ...
	'Display', 'off' );
obj.MultiStartOptions = MultiStart( ...
	'Display', 'off', ...
	'StartPointsToRun', 'bounds', ...
	'UseParallel', obj.opt.BayesParallelMS );

% Check if this is a continued run
if continueBool
	% Set iteration to start from (redo incomplete obj.iter if needed)
	jPrevious = length(obj.iter);
	if obj.iter(jPrevious).completeBool
		j = jPrevious + 1;
	else
		j = jPrevious;
	end
		
else % New Run
	% Initialize with INITIALX
	if isempty(initialX)
		obj = obj.initialize();
	else
		obj = obj.initialize(initialX);
	end

	% Define empty data structure for the run
	obj.iter = struct();

	j = 1;
end

% Set initial sigma if zero (default value)
if obj.opt.noiseSigma <= 0
	tempNoiseSigma = [];
else
	tempNoiseSigma = obj.opt.noiseSigma;
end

% Set handling of invalid results
switch obj.opt.GSinvalidTransform
	case 'none'
		tempYTransform = @(y, valid) y;
	case 'mean'
		tempYTransform = @(y, valid) MOSAO.y_transform_mean(y, valid);
	case 'worst'
		tempYTransform = @(y, valid) MOSAO.y_transform_worst(y, valid);
	case 'remove'
		tempYTransform = @(y, valid) MOSAO.y_transform_remove(y, valid);
	otherwise
		error('MOSAO:UnrecognizedInvalidHandling', 'Unrecognized MOSAO.opt.GSinvalidTransform');
end

% Create initial classification
if obj.opt.GSuseClassifier
	obj.classifier = fitPosterior(fitcsvm( ...
		obj.db.x, ....
		obj.db.valid, ...
		'KernelFunction', 'gaussian', ...
		'KernelScale', 'auto', ...
		'Standardize', true, ...
		'BoxConstraint', 10, ...
		'ClassNames', [false, true] ));
end

% Create initial models
for i = 1:obj.db.lenY
	obj.model{i} = fitrgp( ...
		obj.db.x, ...
		tempYTransform(obj.db.y(:,i), obj.db.valid), ...
		'Standardize', true, ...
		'FitMethod', 'exact', ...
		'PredictMethod', 'exact', ...
		'BasisFunction', obj.opt.GSbasis, ...
		'KernelFunction', obj.opt.GSkernel, ...
		'Sigma', tempNoiseSigma, ...
		'ConstantSigma', obj.opt.constantNoiseSigma	);				
end

% Show messages
if obj.opt.showMessages
	[printP,~,printVol] = MOSAO.pareto_front_hypervolume(obj.db.y(obj.db.valid,:), obj.opt.hypervolumeRef);
	fprintf('%5d %13d %#15.2e %8d\n', j-1, obj.db.callAmount, printVol, size(printP, 1));
end

lastCallAmount = 0;
timeGenList = [];
runningCallAmountList = [];
nParetoList = [];
HVList = [];

% Main loop
while obj.db.callAmount < obj.opt.maxCalls
	timeGenTic = tic;
	obj.iter(j).completeBool = false;
	obj.iter(j).prevCallAmount = obj.db.callAmount;
	
	% Define classifier for GA
	if obj.opt.GSuseClassifier
		tempClassifier = @(kX) MOSAO.classification_probability(kX, obj.classifier);
	else
		tempClassifier = @(kX) 1;
	end
	
	% Define GA criteria based on options
	[tempP, tempYref, tempHV, tempPind] = MOSAO.pareto_front_hypervolume(obj.db.y(obj.db.valid,:), obj.opt.hypervolumeRef);
	switch obj.opt.BayesMOAcqFunc
		case 'HVIncreaseMean'
			acquisitionFunction = @(kX) -1*MOSAO.change_of_hypervolume(tempP, tempYref, tempHV, obj.model, kX, 'meanValue');
		case 'HVIncreaseLCB'
			acquisitionFunction = @(kX) -1*MOSAO.change_of_hypervolume(tempP, tempYref, tempHV, obj.model, kX, 'LCB');
		case 'PoPI'
			acquisitionFunction = @(kX) -1*MOSAO.probability_of_pareto_improvement(tempP, obj.model, kX);
		case 'EHVI'
			acquisitionFunction = @(kX) -1*MOSAO.expected_hypervolume_improvement(tempP, tempYref, tempHV, obj.model, kX);
		otherwise
			error('MOSAO:UnrecognizedGAcriteria', 'Unrecognized obj.opt.GAcriteria');
	end
	
	% Create start points (half random, half from pareto front)
	tempN = length(tempPind);
	tempNset = min(tempN, max(1, floor(obj.opt.BayesNstarts/2)));
	tempNrand = max(1, obj.opt.BayesNstarts - tempNset);
	tempStartPoints = {...
		CustomStartPointSet(obj.db.x(tempPind(randsample(tempN, tempNset)),:)), ...
		RandomStartPointSet('NumStartPoints', tempNrand) };
	
	% Run multistart fmincon to find local minima
	tempProblem = createOptimProblem( ...
		'fmincon',...
		'objective', @(kX) tempClassifier(kX).*acquisitionFunction(kX), ...
		'x0', obj.db.x(1,:), ...
		'lb', obj.db.LB, ...
		'ub', obj.db.UB, ...
		'options', obj.fminconOptions );
	[obj.temp(j).x, obj.temp(j).fval, obj.temp(j).exitflag, ...
	 obj.temp(j).output, obj.temp(j).solutions] = run( ...
		obj.MultiStartOptions, ...
		tempProblem, ...
		tempStartPoints );

	% Check for duplicates
	obj.iter(j).foundMinX = cell2mat({obj.temp(j).solutions.X}');
	obj.iter(j).untestedI = find(~obj.db.check_existence(obj.iter(j).foundMinX));
	obj.iter(j).toUseI = obj.iter(j).untestedI(1:obj.opt.BayesNcandidates);
	
	% Evaluate candidates
	switch obj.opt.type
		case 'b'
			% Evaluate candidate(s) directly
			obj.db = obj.db.call_function(obj.iter(j).foundMinX(obj.iter(j).toUseI,:));
		otherwise
			error('MOSAO:UnrecognizedType', 'Unrecognized obj.opt.type for MO optimization.');
	end
	
	% Update classifier and surrogate model if needed
	if lastCallAmount < obj.db.callAmount
		if obj.opt.GSuseClassifier
			obj.classifier = fitPosterior(fitcsvm( ...
				obj.db.x, ....
				obj.db.valid, ...
				'KernelFunction', 'gaussian', ...
				'KernelScale', 'auto', ...
				'Standardize', true, ...
				'BoxConstraint', 10, ...
				'ClassNames', [false, true] ));
		end
		
		for i = 1:obj.db.lenY
			if obj.opt.reuseKernel
				try
					obj.model{i} = fitrgp( ...
						obj.db.x, ...
						tempYTransform(obj.db.y(:,i), obj.db.valid), ...
						'Standardize', true, ...
						'FitMethod', 'exact', ...
						'PredictMethod', 'exact', ...
						'BasisFunction', obj.opt.GSbasis, ...
						'KernelFunction', obj.opt.GSkernel, ...
						'Sigma', tempNoiseSigma, ...
						'ConstantSigma', obj.opt.constantNoiseSigma, ... 
						'KernelParameters', obj.model{i}.KernelInformation.KernelParameters );
				catch tempME
					switch tempME.identifier
						% If unable to find theta, try again with no theta0 set
						case 'stats:classreg:learning:impl:GPImpl:GPImpl:UnableToComputeLFactorExact'
							warning('MOSAO:DefaultingTheta0', ...
								'Unable to compute theta (kernel) given specified theta0 at j=%d.\nDefaulting to unspecified theta0.', j);
							obj.model{i} = fitrgp( ...
								obj.db.x, ...
								tempYTransform(obj.db.y(:,i), obj.db.valid), ...
								'Standardize', true, ...
								'FitMethod', 'exact', ...
								'PredictMethod', 'exact', ...
								'BasisFunction', obj.opt.GSbasis, ...
								'KernelFunction', obj.opt.GSkernel, ...
								'Sigma', tempNoiseSigma, ...
								'ConstantSigma', obj.opt.constantNoiseSigma );
						otherwise
							rethrow(tempME);
					end
				end
			else
				obj.model{i} = fitrgp( ...
					obj.db.x, ...
					tempYTransform(obj.db.y(:,i), obj.db.valid), ...
					'Standardize', true, ...
					'FitMethod', 'exact', ...
					'PredictMethod', 'exact', ...
					'BasisFunction', obj.opt.GSbasis, ...
					'KernelFunction', obj.opt.GSkernel, ...
					'Sigma', tempNoiseSigma, ...
					'ConstantSigma', obj.opt.constantNoiseSigma );
			end
		end
	end
	
	% Get iteration's pareto state
	[tempP, ~, tempHV] = MOSAO.pareto_front_hypervolume(obj.db.y(obj.db.valid,:), obj.opt.hypervolumeRef);
	
	% Show messages
	if obj.opt.showMessages
		fprintf('%5d %13d %#15.2e %8d\n', j, obj.db.callAmount, tempHV, size(tempP, 1));
	end
	
	lastCallAmount = obj.db.callAmount;
	runningCallAmountList = [runningCallAmountList; obj.db.callAmount];
	timeGenList = [timeGenList; toc(timeGenTic)];
	nParetoList = [nParetoList; size(tempP, 1)];
	HVList = [HVList; tempHV];
	obj.iter(j).completeBool = true;
	j = j+1;
end

% Organize output values, appending values if they already exist
obj = obj.organize_run_outputs(runningCallAmountList, timeGenList, nParetoList, HVList);

end
