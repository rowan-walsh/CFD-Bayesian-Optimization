function [outI] = filter_unique(X, minDistance, rangeX)
%FILTER_UNIQUE Sorts out the unique values in X

% If not provided, set range based on the bounds of X
if nargin < 3
	rangeX = max(X, [], 1) - min(X, [], 1);
end

nX = size(X, 1);
nParam = size(X, 2);

if size(rangeX, 2)==1
	rangeX = rangeX';
end

if nParam ~= length(rangeX)
	error('Length of range does not match X.');
end

distance = @(x,y) norm((x-y)./rangeX, 2);

outI = [];
for i = 1:nX
	tooClose = false;
	for j = outI'
		if distance(X(i,:), X(j,:)) < minDistance
			tooClose = true;
		end
	end
	
	if ~tooClose
		outI = [outI; i];
	end
end

end

