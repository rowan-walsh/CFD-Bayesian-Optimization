function [isValid] = check_bounds(obj, kx)
%CHECK_BOUNDS Checks a list of x values against bounds
%
%	Part of the Database class.

nkx = size(kx, 1);
isValid = false(nkx, 1);

% Check kx is the correct shape
if size(kx, 2) ~= obj.lenX
	warning('kx value(s) are not the correct length');
	return
end

% Determine if each kx value (row) is within the bounds
isValid = and(all(kx >= obj.LB, 2), all(kx <= obj.UB, 2));

end
