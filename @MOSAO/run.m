function [obj] = run(obj, initialX)
%RUN Runs the optimization for the MOSAO class
%   INITIALX:	Row-wise set of X vectors to use as the MOSAO's initial 
%				Database.
%
%				If the Database has fewer than opt.initCalls, this adds
%				more using opt.initType.
%
%	Part of the MOSAO class.


timeTotalTic = tic;

% Turn off unnecessary warning (previous warning state is recovered at cleanup)
originalWarningState = warning('off', 'globaloptim:constrvalidate:unconstrainedMutationFcn');
warning('off', 'stats:cvpartition:KFoldMissingGrp');
warning('off', 'stats:fitSVMPosterior:PerfectSeparation');
finishUp = onCleanup(@() warning(originalWarningState));

% Validate obj.opt (again)
obj.opt = MOSAO.validate_options(obj.opt);

% Initialize with INITIALX
if nargin < 2
	initialX = [];
end

% Show messages
if obj.opt.showMessages
	if obj.db.lenY > 1
		fprintf('Generation      f-count   Hypervolume  n-Pareto\n');
	else
		fprintf('Generation      f-count   Best f(x)\n');
	end
end

% Run algorithm specified in options
switch obj.opt.type
	case 'ga'
		obj = obj.run_ga(false);
	case {'saga-gs','saga-ls','saga-gls'}
		obj = obj.run_saga(initialX, false);
	case {'b','bls'}
		if obj.db.lenY > 1
			obj = obj.run_MO_bayesian(initialX, false);
		else
			obj = obj.run_SO_bayesian(initialX, false);
		end
	otherwise
		error('MOSAO:UnrecognizedType', 'Unrecognized MOSAO.opt.type');
end

obj.final.timeTotal = toc(timeTotalTic);

end
