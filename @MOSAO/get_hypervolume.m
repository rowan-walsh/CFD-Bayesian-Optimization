function [volume] = get_hypervolume(P, Yref)
%GET_HYPERVOLUME Gets the hypervolume of a pareto set P.
%	P		The pareto set
%	Yref	A reference point for the upper bounds of the hypervolume.
%
%	Algorithm from:
%		Seyedali Mirjalili, 2017, Multi-Objective Multi-Verse Optimization
%		(MOMVO) algorithm, MATLAB Package
%		https://www.mathworks.com/matlabcentral/fileexchange/63796-multi-objective-multi-verse-optimization--momvo--algorithm
%
%	Part of the MOSAO class.

% Get number of objectives
nObjectives = size(P, 2);

% Get hypervolume
volume = hypeIndicatorExact8(P, Yref, nObjectives);

end

function [hv, nrW] = hypeIndicatorExact8(A, bounds, dim)

hv  = 0; nrW = 0;
nrA = size(A, 1);
if nrA == 0 % No points
    return;
elseif nrA == 1 % Single point
    hv = prod(bounds - A(1,:));
    nrW = 0;
elseif nrA == 2 % 2 points
    w = max(A(1,:), A(2,:));       
    hv = prod(bounds - A(1,:)) + prod(bounds - A(2,:)) - prod(bounds - w);
%     nrW = 1;   
elseif nrA == 3
    w1 = max(A(1,:), A(2,:));       
    w2 = max(A(1,:), A(3,:));
    w3 = max(A(2,:), A(3,:));
    w4 = max(w1, A(3,:));
    hv = prod(bounds - A(1,:)) ...
		+ prod(bounds - A(2,:)) ...
		+ prod(bounds - A(3,:)) ...
		- prod(bounds - w1) ...
		- prod(bounds - w2) ...
		- prod(bounds - w3) ...
		+ prod(bounds - w4);
elseif dim == 2
        %the points are slice to 2d, same values in other dimensions
        hv = hypervolume2(A(:,1:2), bounds(1:2));
        for i = 3:size(A,2)
            hv = hv * (bounds(i) - A(1,i));
        end
        nrW = 0;
else    
    A = sortrows(A, dim);
    while A(nrA, dim) == A(1, dim)
%         fprintf('s');
        dim = dim - 1;
        A = sortrows(A, dim);
    end
    if dim == 2
        %the points are slice to 2d, same values in other dimensions
        hv = hypervolume2(A(:,1:2), bounds(1:2));
        for i = 3:size(A,2)
            hv = hv * (bounds(i) - A(1,i));
        end
        nrW = 0;
        %     nrW = nrA - 1;
    else
        hv = hv + prod(bounds - A(1,:));
        for i = nrA:-1:2
            v = prod(bounds - A(i,:));
            if v > 0
                W = worse(A(i,:), A(1:i-1,:));
                [hv1, nrW1] = hypeIndicatorExact8(W, bounds, dim - 1);
                hv = hv + v - hv1;
                nrW = nrW + size(W,1) +nrW1;
            end
        end
    end
end

end

function [W] = worse(A1, A2) 
%how to quickly get the worse set

[nrA1, dim] = size(A1);
nrA2 = size(A2,1);
W = zeros(nrA1 * nrA2, dim);
nrW = 0;
for i = 1:nrA1
    worse = max(repmat(A1(i,:), nrA2, 1), A2);    
    %find the non-dominated points in worse    
    for j = nrA2:-1:1  
        %the index (nrA2:-1:1) is important, because the last one is alwasys better (nondominated) than others
        [W, nrW] = insertPoint(worse(j,:), W, nrW);
    end
end
%find the non-equal, and non-dominated points in W
W = W(1:nrW,:);

end

function [W, nrW] = insertPoint(p, W, nrW)

if nrW == 0
    W(1,:) = p;
    nrW = 1;
else
    dim = size(p,2);
    i = 1;
    while i <= nrW
        diff = p - W(i,:);
        if sum(diff >=0, 2) == dim
            %same point, or p is dominated
%             fprintf('%c', '1');  
            return;
        end
        if sum(diff <=0, 2) == dim
            %some points in W are dominated by p
            W(i, :) = W(nrW, :);
%             fprintf('%c', '2'); 
            i = i - 1;
            nrW = nrW - 1;
        end
        i = i + 1;
    end
    %non-dominated each other, add this point
    nrW = nrW + 1;
    W(nrW,:) = p;    
end
    
end

function [hv] = hypervolume2(A, bounds)
%%get hypervolume for 2D

hv = 0;
[nrA, dim] = size(A);
if nrA == 0
    return;
end
A = sortrows(A, dim);
for i=1:nrA-1
    hv = hv + (A(i+1, 2) - A(i, 2)) * (bounds(1) - A(i,1));
end
hv = hv + (bounds(2) - A(nrA, 2)) * (bounds(1) - A(nrA,1));

end
