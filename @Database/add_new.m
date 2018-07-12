function [obj, iNew] = add_new(obj, kx, ky, kvalid)
%ADD_NEW Adds to the Database from given values
%
%	Part of the Database class.

% Check kx is the correct shape
if size(kx, 2) ~= obj.lenX
	iNew = zeros(0, 1);
	warning('kx value(s) are not the correct length');
	return
end

% Check kx is within bounds
if ~all(obj.check_bounds(kx))
	iNew = zeros(0, 1);
	warning('kx value(s) are not within the bounds');
	return
end

% Define number of values to call function with
nkx = size(kx, 1);

% Check inputs for size
if any(size(ky) ~= [nkx, obj.lenY])
	error('ky (%dx%d) was not the expected size of (%dx%d)', ...
		size(ky, 1), size(ky, 2), nkx, obj.lenY);
end
if any(size(kvalid) ~= [nkx, 1])
	error('kvalid (%dx%d) was not the expected size of (%dx%d)', ...
		size(kvalid, 1), size(kvalid, 2), nkx, 1);
end

% Return indices of results
iNew = obj.callAmount + (1:nkx)';

% Assign object parameters
obj.callAmount = obj.callAmount + nkx;
obj.x = [obj.x; kx];
obj.y = [obj.y; ky];
obj.valid = [obj.valid; logical(kvalid)];

% Track sets of function evaluations
obj.currentCall = obj.currentCall + 1;
obj.call = [obj.call; obj.currentCall*ones(nkx, 1)];

end
