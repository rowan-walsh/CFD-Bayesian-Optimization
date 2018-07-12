function [iNeighbors] = nearest_neighbors(obj, kx, n, validOnly)
%NEAREST_NEIGHBORS Finds indices of N nearest X values to KX.
%
%	[iNeighbors] = nearest_neighbors(OBJ, KX, N, VALIDONLY)
%		Finds the nearest N neighbors to KX in OBJ.X.
%		KX must be of size [1, OBJ.LENX].
%
%		VALIDONLY - boolean: specifies if only valid x are used
%
%	Part of the Database class.

if nargin < 4
	validOnly = false;
	if nargin < 3
		n = 1;
	end
end

iNeighbors = [];
rangeX = obj.UB - obj.LB;
tempDistances = sum(((obj.x - kx)./rangeX).^2, 2);

% Set invalid to NaN if required
if validOnly
	tempDistances(~obj.valid) = NaN;
end

% Check kx is the correct shape
if any(size(kx) ~= [1, obj.lenX])
	warning('kx value is not the correct length');
	return
end

% Sort and select indices
[~, iTemp] = sort(tempDistances, 'ascend');
iNeighbors = iTemp(1:min(n, end));

end
