function [obj] = run_saga(obj, initialX, continueBool)
%RUN_SAGA Runs a SAGA optimization
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

% Define options struct for genetic algorithm
obj.gaOptions = optimoptions('ga', ...
	'Display',			 'off', ...
	'MaxGenerations',	 obj.opt.GAgenerations, ...
	'PopulationSize',	 obj.opt.populationSize, ...
	'CrossoverFraction', obj.opt.crossoverRatio, ...
	'UseVectorized',	 true, ...
	'MutationFcn',		 {@mutationuniform, obj.opt.mutationRate}, ...
	'InitialPopulationMatrix', [] );

% Check if this is a continued run
if continueBool
	% Set iteration to start from (redo incomplete obj.iter if needed)
	jPrevious = length(obj.iter);
	if obj.iter(jPrevious).completeBool
		j = jPrevious + 1;
	else
		j = jPrevious;
	end
	
	% Change GA initial population to previous final complete iteration population
	if j > 1
		obj.gaOptions.InitialPopulationMatrix = obj.iter(j-1).population;
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

% Create initial model
obj.model = fitrgp( ...
	obj.db.x, ...
	tempYTransform(obj.db.y, obj.db.valid), ...
	'Standardize', true, ...
	'FitMethod', 'exact', ...
	'PredictMethod', 'exact', ...
	'BasisFunction', obj.opt.GSbasis, ...
	'KernelFunction', obj.opt.GSkernel, ...
	'Sigma', tempNoiseSigma, ...
	'ConstantSigma', obj.opt.constantNoiseSigma	);

% Show messages
if obj.opt.showMessages
	fprintf('%5d %13d %#15.2e\n', j-1, obj.db.callAmount, min(obj.db.y(obj.db.valid)));
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
	switch obj.opt.GAcriteria
		case 'fitness'
			tempGAcriteria = @(kX) predict(obj.model, kX);
		case 'PoI'
			tempGAcriteria = @(kX) -1*MOSAO.probability_of_improvement(kX, obj.model, min(obj.db.y(obj.db.valid)));
		case 'EI'
			tempGAcriteria = @(kX) -1*MOSAO.expected_improvement(kX, obj.model, min(obj.db.y(obj.db.valid)));
		otherwise
			error('MOSAO:UnrecognizedGAcriteria', 'Unrecognized MOSAO.opt.GAcriteria');
	end
	
	% Run a generation of GA
	[obj.temp(j).x, obj.temp(j).fval, obj.temp(j).exitflag, ...
	 obj.temp(j).output, obj.iter(j).population, ...
	 obj.iter(j).scores] = ga( ...
		@(kX) tempClassifier(kX).*tempGAcriteria(kX), ... % fitness function
		obj.db.lenX, ... % nVars
		[], [], ... % A, b
		[], [], ... % Aeq, Beq
		obj.db.LB, obj.db.UB, ... % LB, UB
		[], [], ... % nonLCon, IntCon
		obj.gaOptions ); % options struct
	
	switch obj.opt.type
		case {'saga-gs', 'saga-gls'}
			% Find new (untested) individuals, determine scores for sorting
			obj.iter(j).untestedI = find(~obj.db.check_existence(obj.iter(j).population));
			switch obj.opt.sortCriteria
				case 'fitness'
					tempSortCriteria = @(kX) predict(obj.model, kX);
				case 'PoI'
					tempSortCriteria = @(kX) -1*MOSAO.probability_of_improvement(kX, obj.model, min(obj.db.y(obj.db.valid)));
				case 'EI'
					tempSortCriteria = @(kX) -1*MOSAO.expected_improvement(kX, obj.model, min(obj.db.y(obj.db.valid)));
				otherwise
					error('MOSAO:UnrecognizedSortCriteria', 'Unrecognized MOSAO.opt.sortCriteria');
			end
			obj.temp(j).untestedPopulation = obj.iter(j).population(obj.iter(j).untestedI, :);
			obj.temp(j).untestedScores = tempClassifier(obj.temp(j).untestedPopulation).*tempSortCriteria(obj.temp(j).untestedPopulation);

			% Get candidates from sorted individuals
			obj.temp(j).outI = MOSAO.filtered_sort( ...
				obj.temp(j).untestedPopulation, ...
				obj.temp(j).untestedScores, ...
				obj.opt.maxCandidates, ...
				obj.opt.minSortDistance, ...
				obj.db.UB - obj.db.LB);
			obj.iter(j).candidateI = obj.iter(j).untestedI(obj.temp(j).outI);
		case 'saga-ls'
			obj.iter(j).untestedI = find(~obj.db.check_existence(obj.iter(j).population));
			obj.temp(j).untestedPopulation = obj.iter(j).population(obj.iter(j).untestedI, :);
			
			% Get candidates from filtered individuals
			obj.temp(j).outI = MOSAO.filter_unique( ...
				obj.temp(j).untestedPopulation, ...
				obj.opt.minSortDistance, ...
				obj.db.UB - obj.db.LB);
			obj.iter(j).candidateI = obj.iter(j).untestedI(obj.temp(j).outI);
		otherwise
			error('MOSAO:UnrecognizedMOSAOType', 'Unrecognized MOSAO.opt.type');
	end
	
	% Evaluate candidates/do learning
	switch obj.opt.type
		case {'saga-ls', 'saga-gls'}
			% Do local search (learning) on each candidate
			obj.temp(j).oldPopulation = obj.iter(j).population;
			for k = obj.iter(j).candidateI'
				[obj, tempX] = obj.local_search(obj.iter(j).population(k,:));
				if ~isempty(tempX) % Replace candidate if improved with local search
					obj.iter(j).population(k,:) = tempX;
				end
			end
		case 'saga-gs'
			% Evaluate candidates directly
			obj.db = obj.db.call_function(obj.iter(j).population(obj.iter(j).candidateI,:));
		otherwise
			error('MOSAO:UnrecognizedMOSAOType', 'Unrecognized MOSAO.opt.MOSAOtype');
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
				obj.model = fitrgp( ...
					obj.db.x, ...
					tempYTransform(obj.db.y, obj.db.valid), ...
					'Standardize', true, ...
					'FitMethod', 'exact', ...
					'PredictMethod', 'exact', ...
					'BasisFunction', obj.opt.GSbasis, ...
					'KernelFunction', obj.opt.GSkernel, ...
					'Sigma', tempNoiseSigma, ...
					'ConstantSigma', obj.opt.constantNoiseSigma, ... 
					'KernelParameters', obj.model.KernelInformation.KernelParameters );
			catch tempME
				switch tempME.identifier
					% If unable to find theta, try again with no theta0 set
					case 'stats:classreg:learning:impl:GPImpl:GPImpl:UnableToComputeLFactorExact'
						warning('MOSAO:DefaultingTheta0', ...
							'Unable to compute theta (kernel) given specified theta0 at j=%d.\nDefaulting to unspecified theta0.', j);
						obj.model = fitrgp( ...
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
			obj.model = fitrgp( ...
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
	end
	
	% Reuse population
	obj.gaOptions.InitialPopulationMatrix = obj.iter(j).population;
	
	% Display results
	if obj.opt.showMessages
		fprintf('%5d %13d %#15.2e\n', j, obj.db.callAmount, min(obj.db.y(obj.db.valid)));
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

