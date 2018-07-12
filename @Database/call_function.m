function [obj, iCalled] = call_function(obj, kx)
%CALL_FUNCTION Adds to the Database by calling the function
%
%	Part of the Database class.

% Check kx is the correct shape
if size(kx, 2) ~= obj.lenX
	iCalled = zeros(0, 1);
	warning('kx value(s) are not the correct length');
	return
end

% Check kx is within bounds
if ~all(obj.check_bounds(kx))
	iCalled = zeros(0, 1);
	warning('kx value(s) are not within the bounds');
	return
end

% Define number of values to call function with
nkx = size(kx, 1);

% Call function with exception handling
[tempY, tempValid] = obj.fHandle(kx);

% Check function outputs
if any(size(tempY) ~= [nkx, obj.lenY])
	error('Function output Y (%dx%d) was not the expected size of (%dx%d)', ...
		size(tempY, 1), size(tempY, 2), nkx, obj.lenY);
end
if any(size(tempValid) ~= [nkx, 1])
	error('Function output Valid (%dx%d) was not the expected size of (%dx%d)', ...
		size(tempValid, 1), size(tempValid, 2), nkx, 1);
end

% Return indices of results
iCalled = obj.callAmount + (1:nkx)';

% Assign object parameters
obj.callAmount = obj.callAmount + nkx;
obj.x = [obj.x; kx];
obj.y = [obj.y; tempY];
obj.valid = [obj.valid; logical(tempValid)];

% Track sets of function evaluations
obj.currentCall = obj.currentCall + 1;
obj.call = [obj.call; obj.currentCall*ones(nkx, 1)];

end
