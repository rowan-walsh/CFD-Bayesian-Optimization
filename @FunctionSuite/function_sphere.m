function [y, valid] = function_sphere(x, bounded)
%FUNCTION_SPHERE  Sphere test function, x is a row-wise list of vectors
%	Commonly used test function
%	Part of the FunctionSuite class

lenX = size(x, 2);
b = 1:min(2, lenX);

y = sum(x.^2, 2);

if bounded
	valid = and(not(any(isnan(y), 2)), all(x(:,b) >= 0, 2));
	y(~valid) = 10000;
else
	valid = not(any(isnan(y), 2));
end

end
