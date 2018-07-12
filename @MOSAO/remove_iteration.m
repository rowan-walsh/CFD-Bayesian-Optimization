function [obj] = remove_iteration(obj, iteration)
%REMOVE_ITERATION Removes iteration(s) from a MOSAO run
%
%	Part of the MOSAO class.

% Check validity of iterations
if any(iteration <= 0) || any(iteration > length(obj.iter))
	error('MOSOA:badIter', 'Invalid iteration passed to remove_iteration()');
end

obj.iter(iteration) = [];
obj.temp(iteration) = [];

end
