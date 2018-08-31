function [obj] = run_SO_bayesian(obj, initialX, continueBool)
%RUN_SO_BAYESIAN Runs a single-objective Bayesian optimization
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

% Set handling of acquisition function marginalization
switch obj.opt.AcqMarginalization
	case 'none'
		tempAcqMargin = @(x, models, acqFunc) acqFunc(x, models);
	case 'sliceSample'
		tempAcqMargin = @(x, models, acqFunc) MOSAO.acquisition_mean(x, models, acqFunc);
	otherwise
		error('MOSAO:UnrecognizedAcqusitionSamplingType', 'Unrecognized MOSAO.opt.AcqMarginalization');
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

% Create initial model(s)
obj.initModel = fitrgp( ...
	obj.db.x, ...
	tempYTransform(obj.db.y, obj.db.valid), ...
	'Standardize', true, ...
	'FitMethod', 'exact', ...
	'PredictMethod', 'exact', ...
	'BasisFunction', obj.opt.GSbasis, ...
	'KernelFunction', obj.opt.GSkernel, ...
	'Sigma', tempNoiseSigma, ...
	'ConstantSigma', obj.opt.constantNoiseSigma	);
switch obj.opt.AcqMarginalization
	case 'none'
		obj.model = obj.initModel;
	case 'sliceSample'
		obj.model = MOSAO.slice_sample_models(obj.initModel, obj.opt.AcqSamples, obj.opt.AcqNBurnin, obj.opt.AcqNThin);
	otherwise
		error('MOSAO:UnrecognizedAcqusitionSamplingType', 'Unrecognized MOSAO.opt.AcqMarginalization');
end
		
% Show messages
if obj.opt.showMessages
	fprintf('%5d %13d %#15.3e\n', j-1, obj.db.callAmount, min(obj.db.y(obj.db.valid)));
end

lastCallAmount = 0;
timeGenList = [];
runningCallAmountList = [];

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
	switch obj.opt.BayesAcqFunc
		case 'fitness'
			%acquisitionFunction = @(kX) MOSAO.mean_prediction(kX, obj.model);
			acquisitionFunction = @(kX) tempAcqMargin(kX, obj.model, @MOSAO.mean_prediction);
		case 'PoI'
			%acquisitionFunction = @(kX) -1*MOSAO.probability_of_improvement(kX, obj.model, min(obj.db.y(obj.db.valid)));
			acquisitionFunction = @(kX) -1*tempAcqMargin(kX, obj.model, @(x, mod) MOSAO.probability_of_improvement(x, mod, min(obj.db.y(obj.db.valid))));
		case 'EI'
			%acquisitionFunction = @(kX) -1*MOSAO.expected_improvement(kX, obj.model, min(obj.db.y(obj.db.valid)));
			acquisitionFunction = @(kX) -1*tempAcqMargin(kX, obj.model, @(x, mod) MOSAO.expected_improvement(x, mod, min(obj.db.y(obj.db.valid))));
		otherwise
			error('MOSAO:UnrecognizedGAcriteria', 'Unrecognized MOSAO.opt.GAcriteria');
	end
	
	% Run multistart fmincon to find local minima
	[~, tempMinInd] = min(obj.db.y(obj.db.valid));
	tempProblem = createOptimProblem( ...
		'fmincon',...
		'objective', @(kX) tempClassifier(kX).*acquisitionFunction(kX), ...
		'x0', obj.db.x(tempMinInd,:), ...
		'lb', obj.db.LB, ...
		'ub', obj.db.UB, ...
		'options', obj.fminconOptions );

	[obj.temp(j).x, obj.temp(j).fval, obj.temp(j).exitflag, ...
	 obj.temp(j).output, tempSolutions] = run( ...
		obj.MultiStartOptions, ...
		tempProblem, ...
		obj.opt.BayesNstarts );
	
	% Check for duplicates
	obj.iter(j).foundMinX = cell2mat({tempSolutions.X}');
	obj.iter(j).untestedI = find(~obj.db.check_existence(obj.iter(j).foundMinX));
	
	% If not enough (non-duplicate) candidate points are found, use random points
	nUntested = length(obj.iter(j).untestedI);
	if nUntested < obj.opt.BayesNcandidates
		obj.iter(j).toUseX = [ ...
			obj.iter(j).foundMinX(obj.iter(j).untestedI(1:nUntested),:); ...
			obj.db.LB + (obj.db.UB - obj.db.LB).*rand(obj.opt.BayesNcandidates - nUntested, obj.db.lenX) ];
	else
		obj.iter(j).toUseX = obj.iter(j).foundMinX(obj.iter(j).untestedI(1:obj.opt.BayesNcandidates),:);
	end
	%obj.iter(j).toUseI = obj.iter(j).untestedI(1:obj.opt.BayesNcandidates);
			
	% Evaluate candidates
	switch obj.opt.type
		case 'bls'
			% Do local search on each candidate (no need for learning with Bayesian)
			for k = 1:obj.opt.BayesNcandidates
				[obj,~,~] = obj.local_search(obj.iter(j).toUseX(k,:));
			end
		case 'b'
			% Evaluate candidate(s) directly
			obj.db = obj.db.call_function(obj.iter(j).toUseX);
		otherwise
			error('MOSAO:UnrecognizedType', 'Unrecognized MOSAO.opt.type');
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
		
		if obj.opt.reuseKernel
			try
				obj.initModel = fitrgp( ...
					obj.db.x, ...
					tempYTransform(obj.db.y, obj.db.valid), ...
					'Standardize', true, ...
					'FitMethod', 'exact', ...
					'PredictMethod', 'exact', ...
					'BasisFunction', obj.opt.GSbasis, ...
					'KernelFunction', obj.opt.GSkernel, ...
					'Sigma', tempNoiseSigma, ...
					'ConstantSigma', obj.opt.constantNoiseSigma, ... 
					'KernelParameters', obj.initModel.KernelInformation.KernelParameters );
			catch tempME
				switch tempME.identifier
					% If unable to find theta, try again with no theta0 set
					case 'stats:classreg:learning:impl:GPImpl:GPImpl:UnableToComputeLFactorExact'
						warning('MOSAO:DefaultingTheta0', ...
							'Unable to compute theta (kernel) given specified theta0 at j=%d.\nDefaulting to unspecified theta0.', j);
						obj.initModel = fitrgp( ...
							obj.db.x, ...
							tempYTransform(obj.db.y, obj.db.valid), ...
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
			obj.initModel = fitrgp( ...
				obj.db.x, ...
				tempYTransform(obj.db.y, obj.db.valid), ...
				'Standardize', true, ...
				'FitMethod', 'exact', ...
				'PredictMethod', 'exact', ...
				'BasisFunction', obj.opt.GSbasis, ...
				'KernelFunction', obj.opt.GSkernel, ...
				'Sigma', tempNoiseSigma, ...
				'ConstantSigma', obj.opt.constantNoiseSigma );
		end
		
		% Update model(s) for acquisition functions
		switch obj.opt.AcqMarginalization
			case 'none'
				obj.model = obj.initModel;
			case 'sliceSample'
				obj.model = MOSAO.slice_sample_models(obj.initModel, obj.opt.AcqSamples, obj.opt.AcqNBurnin, obj.opt.AcqNThin);
			otherwise
				error('MOSAO:UnrecognizedAcqusitionSamplingType', 'Unrecognized MOSAO.opt.AcqMarginalization');
		end
	end
	
	% Display results
	if obj.opt.showMessages
		fprintf('%5d %13d %#15.3e\n', j, obj.db.callAmount, min(obj.db.y(obj.db.valid)));
	end
	
	lastCallAmount = obj.db.callAmount;
	runningCallAmountList = [runningCallAmountList; obj.db.callAmount];
	timeGenList = [timeGenList; toc(timeGenTic)];
	obj.iter(j).completeBool = true;
	j = j+1;
end

% Organize output values, appending values if they already exist
obj = obj.organize_run_outputs(runningCallAmountList, timeGenList);

end
