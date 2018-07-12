function [y, valid] = function_ellipsoid(x, bounded)
%FUNCTION_ELLIPSOID  Ellipsoid test function, x is a row-wise list of vectors
%	Commonly used test function
%	Part of the FunctionSuite class

lenX = size(x, 2);
b = 1:min(2, lenX);

ind = 1:size(x,2);
y = sum((ind.*x).^2, 2);

if bounded
	valid = and(not(any(isnan(y), 2)), all(x(:,b) >= 0, 2));
	y(~valid) = 10000;
else
	valid = not(any(isnan(y), 2));
end

end
