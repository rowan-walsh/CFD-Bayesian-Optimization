function [P, Pind] = pareto_front(Y)
%PARETO_FRONT Finds pareto optimal points of a dataset
% Filters a set of points Y according to Pareto dominance, i.e., points
% that are dominated (both weakly and strongly) are filtered out.
%
% Inputs: 
% - Y    : N-by-D matrix, where N is the number of points and D is the 
%          number of elements (objectives) of each point.
%
% Outputs:
% - P	: Pareto-filtered P
% - ind	: indices of the non-dominated solutions
%
% Example:
% p = [1 1 1; 2 0 1; 2 -1 1; 1, 1, 0];
% [f, ind] = pareto_front(p)
%     f = [1 1 1; 2 0 1]
%     ind = [1; 2]

[size1, dim] = size(Y);
Pind = (1:size1)';
indBool = true(size1,1);

for j = 1:size1
	if indBool(j)
		removeIndices = all(Y(j,:) <= Y, 2);
		%removeIndices = all(bsxfun(@le, Y(j,:), Y), 2);
		%removeIndices = sum( bsxfun(@le, Y(j,:), Y), 2) == dim;
		
		removeIndices(j) = false;
		indBool(removeIndices) = false;
	end
end

P = Y(indBool,:);
Pind = Pind(indBool);

end

