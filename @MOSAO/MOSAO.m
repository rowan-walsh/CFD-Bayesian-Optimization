classdef MOSAO < handle
	%MOSAO Multi-objective surrogate-assised optimization
	%   Used to setup, run, and store results from a multi-objective 
	%	surrogate-assisted optimization.
	%
	%	Requires MATLAB's Statistics and Machine Learning Toolbox
	
	properties (SetAccess = public, GetAccess = public)
		% Public read/write properties
		opt
	end
	
	properties (SetAccess = private, GetAccess = public)
		% Public read-only properties
		db
		gaOptions
		fminconOptions
		MultiStartOptions
		iter
		temp
		classifier
		initModel
		model
		final
	end
	
	methods
		function obj = MOSAO(functionHandle, lengthX, lengthY, lowerBound, upperBound, options)
		%MOSAO Class constructor method
		
			% Set default inputs
			if nargin < 6
				options = [];
				if nargin < 5
					upperBound = [];
					if nargin < 4
						lowerBound = [];
						if nargin < 3
							lengthY = 1;
							if nargin < 2
								lengthX = 1;
								if nargin < 1
									functionHandle = @(x) 0;
								end
							end
						end
					end
				end
			end
			
			% Fill in empty bounds
			if isempty(upperBound), upperBound = 1000*ones(1, lengthX); end
			if isempty(lowerBound), lowerBound = -1000*ones(1, lengthX); end
			
			% Transpose bounds if needed
			if size(lowerBound, 1) ~= 1
				lowerBound = transpose(lowerBound);
			end
			if size(upperBound, 1) ~= 1
				upperBound = transpose(upperBound);
			end
			
			% Check size of bounds
			if (size(lowerBound, 2) ~= lengthX) || (size(lowerBound, 1) ~= 1)
				error('MOSAO:InvalidInputs', 'lowerBound must be a vector with length = lengthX');
			end
			if (size(upperBound, 2) ~= lengthX) || (size(upperBound, 1) ~= 1)
				error('MOSAO:InvalidInputs', 'upperBound must be a vector with length = lengthX');
			end
			
			% Check bounds do not overlap
			if any(lowerBound > upperBound)
				error('MOSAO:InvalidInputs', 'Some lowerBounds are greater than upperBound');
			end
			
			% Create object's Database
			obj.db = Database(functionHandle, lengthX, lengthY, lowerBound, upperBound);
			
			% Validate options struct
			obj.opt = MOSAO.validate_options(options);
			
			% Create initial empty internal structs
			obj.gaOptions = [];
			obj.fminconOptions = [];
			obj.MultiStartOptions = [];
			obj.iter = [];
			obj.temp = [];
			obj.classifier = [];
			obj.initModel = cell(0);
			obj.model = cell(0);
			obj.final = [];
		end
		
		% Public methods
		[obj] = run(obj, initialX); % Runs optimization
		[obj] = continue_run(obj); % Picks up a previous run
		[obj] = initialize(obj, initialX); % Runs initial set of X values
		[obj, X, data] = local_search(obj, initialX); % Performs a local search
		[obj] = remove_iteration(obj, iteration); % Removes iteration(s)
	end
	
	methods(Access = private)
		[obj] = run_ga(obj, continueBool);
		[obj] = run_saga(obj, initialX, continueBool);
		[obj] = run_MO_bayesian(obj, initialX, continueBool);
		[obj] = run_SO_bayesian(obj, initialX, continueBool);
		[obj] = organize_run_outputs(obj, runningCallAmountList, timeGenList, nParetoList, HVList);
	end
	
	methods(Static = true) % Static methods
		[validOptions, validBool] = validate_options(options);
		
		[PoV] = classification_probability(X, model);
		[mean] = mean_prediction(X, model);
		[PoI] = probability_of_improvement(X, model, fmin);
		[EI] = expected_improvement(X, model, fmin);
		
		[outI, sortI] = filtered_sort(X, value, n, minDistance, rangeX);
		[outI] = filter_unique(X, minDistance, rangeX);
		
		[outY] = y_transform_mean(Y, valid);
		[outY] = y_transform_worst(Y, valid);
		[outY] = y_transform_remove(Y, valid);

		[P, Pind] = pareto_front(Y);
		[volume] = get_hypervolume(P, Yref);
		[P, Yref, volume, Pind] = pareto_front_hypervolume(Y, Yref);
		[change] = change_of_hypervolume(P, Yref, HVprev, models, Xnew, type);
		[prob] = get_dominated_probability(P, Y, s);
		[PoPI] = probability_of_pareto_improvement(P, models, Xnew);
		[EHVI] = expected_hypervolume_improvement(P, Yref, HVprev, models, Xnew);
		[y] = get_2D_attainment_points(P, Yref);
		[y] = get_2D_summary_attainment_surface(Pset, Yref, method, nSamples);
		
		[meanOutput] = acquisition_mean(x, models, acqFunc);
		[modelArray] = slice_sample_models(initModel, nSamples, nBurnin, nThin);
	end	
end
