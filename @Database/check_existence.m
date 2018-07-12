function [iExists] = check_existence(obj, kx)
%CHECK_EXISTENCE Checks if any x values have already been tested
%
%	[iExists] = check_existence(OBJ, KX)
%		For each KX(i,:), returns the first index of a match in the
%		Database, or returns 0 if there is no match.
%
%	Part of the Database class.

nkx = size(kx, 1);
iExists = zeros(nkx, 1);
minDistance = 1e-10;

% Check kx is the correct shape
if size(kx, 2) ~= obj.lenX
	warning('kx value(s) are not the correct length');
	return
end

% Get indices of existing x values
for i = 1:nkx
	%temp = all(kx(i,:) == obj.x, 2);
	temp = sum((obj.x - kx(i,:)).^2, 2) < minDistance;
	if any(temp)
		iExists(i) = find(temp, 1, 'first');
	end
end

end
