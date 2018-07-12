function [obj] = continue_run(obj)
%CONTINUE_RUN Picks up a previous MOSAO run
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
		obj = obj.run_ga(true);
	case {'saga-gs','saga-ls','saga-gls'}
		obj = obj.run_saga([], true);
	case {'b','bls'}
		if obj.db.lenY > 1
			obj = obj.run_MO_bayesian([], true);
		else
			obj = obj.run_SO_bayesian([], true);
		end
	otherwise
		error('MOSAO:UnrecognizedMOSAOType', 'Unrecognized MOSAO.opt.type');
end

% Record total time taken, add to previous total if it exists
if ~isfield(obj.final, 'timeTotal') || isempty(obj.final.timeTotal)
	obj.final.timeTotal = toc(timeTotalTic);
else
	obj.final.timeTotal = obj.final.timeTotal + toc(timeTotalTic);
end

end
