function [outI, sortI] = filtered_sort(X, value, n, minDistance, rangeX)
%FILTERED_SORT Sorts the n lowest values that are not too close together

% If not provided, set range based on the bounds of X
if nargin < 5
	rangeX = max(X, [], 1) - min(X, [], 1);
end

nX = size(X, 1);
nParam = size(X, 2);

if nX ~= length(value)
	error('Length of value does not match X.');
end

if size(rangeX, 2)==1
	rangeX = rangeX';
end

if nParam ~= length(rangeX)
	error('Length of range does not match X.');
end

if n>nX
	%warning('n is greater than nX');
	n = nX;
end

distance = @(x,y) norm((x-y)./rangeX, 2);

[~,sortI] = sort(value, 'ascend'); % sort for minimum value at top of list

outI = [];
for i = sortI'
	tooClose = false;
	for j = outI'
		if distance(X(i,:), X(j,:)) < minDistance
			tooClose = true;
		end
	end
	
	if ~tooClose
		outI = [outI; i];
	end
	
	if length(outI)>=n
		break;
	end
end

end

