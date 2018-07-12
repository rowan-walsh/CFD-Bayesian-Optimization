function [y, valid] = function_ackley(x, bounded)
%FUNCTION_ACKLEY  Ackley test function, x is a row-wise list of vectors
%	Commonly used test function
%	Part of the FunctionSuite class

lenX = size(x, 2);
b = 1:min(2, lenX);

y = 20 + exp(1) + ...
	-20*exp(-0.2*sqrt(sum(x.^2, 2)/lenX)) + ...
	-1*exp(sum(cos(2*pi*x), 2)/lenX);

if bounded
	valid = and(not(any(isnan(y), 2)), all(x(:,b) >= 0, 2));
	y(~valid) = 10000;
else
	valid = not(any(isnan(y), 2));
end

end
