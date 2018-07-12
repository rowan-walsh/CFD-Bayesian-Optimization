function [obj] = run_ga(obj, continueBool)
%RUN_GA Private function for running a plain-GA optimization
%
%	CONTINUEBOOL:	Indicates if the run is a continuation of a previous
%					run, which could be incomplete.
%
%	Part of the MOSAO class. Private method.


% If no previous run data exists, cannot continue from past run
if isempty(obj.iter)
	continueBool = false;
end

% Set optimization messages on or off
if obj.opt.showMessages
	displayType = 'iter';
else
	displayType = 'none';
end

% Define options struct for genetic algorithm
if obj.db.lenY > 1 % Multi-objective
	obj.gaOptions = optimoptions('gamultiobj', ...
		'Display',				displayType, ...
		'PopulationSize',		obj.opt.populationSize, ...
		'CrossoverFraction',	obj.opt.crossoverRatio, ...
		'UseVectorized',		true, ...
		'MutationFcn',			{@mutationuniform, obj.opt.mutationRate}, ...
		'OutputFcn',			@(opt, st, fl) ga_output_func(opt, st, fl, obj.db, obj.opt.maxCalls) ...
		);
else
	obj.gaOptions = optimoptions('ga', ...
		'Display',				displayType, ...
		'PopulationSize',		obj.opt.populationSize, ...
		'CrossoverFraction',	obj.opt.crossoverRatio, ...
		'UseVectorized',		true, ...
		'MutationFcn',			{@mutationuniform, obj.opt.mutationRate}, ...
		'OutputFcn',			@(opt, st, fl) ga_output_func(opt, st, fl, obj.db, obj.opt.maxCalls) ...
		);
end

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
	% Define data structure for the run
	obj.iter = struct();
	
	j = 1;
end

timeGenTic = tic;
obj.iter(j).completeBool = false;

% Run GA
if obj.db.lenY > 1 % Multi-objective
	[obj.temp(j).x, obj.temp(j).fval, obj.temp(j).exitflag, ...
	 obj.temp(j).output, obj.iter(j).population, ...
	 obj.iter(j).scores] = gamultiobj( ...
		@(x) ga_fitness_func(x, obj.db), ... % fitness function
		obj.db.lenX, ... % nVars
		[], [], ... % A, b
		[], [], ... % Aeq, Beq
		obj.db.LB, obj.db.UB, ... % LB, UB
		obj.gaOptions ); % options struct
else % Single-objective
	[obj.temp(j).x, obj.temp(j).fval, obj.temp(j).exitflag, ...
	 obj.temp(j).output, obj.iter(j).population, ...
	 obj.iter(j).scores] = ga( ...
		@(x) ga_fitness_func(x, obj.db), ... % fitness function
		obj.db.lenX, ... % nVars
		[], [], ... % A, b
		[], [], ... % Aeq, Beq
		obj.db.LB, obj.db.UB, ... % LB, UB
		[], [], ... % nonLCon, IntCon
		obj.gaOptions ); % options struct
end

obj.iter(j).completeBool = true;

% Organize output values, appending values if they already exist
obj = obj.organize_run_outputs(obj.db.callAmount, toc(timeGenTic));

end

% Helper function: GA fitness
function [y] = ga_fitness_func(x, db)
	[~,iCalled] = db.call_function(x);
	y = db.y(iCalled);
end

% Helper function: GA output/call amount tracker
function [state, options, optchanged] = ga_output_func(options, state, flag, db, maxCalls)
	optchanged = false;

	switch flag
		case {'iter','interrupt'}
			if db.callAmount >= maxCalls
				state.StopFlag  = 'Max function evaluations reached';
			end
	end
end
