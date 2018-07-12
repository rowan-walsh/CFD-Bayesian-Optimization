function [y, valid] = function_step(x)
%FUNCTION_STEP  Step test function, x is a row-wise list of vectors
%	Commonly used test function
%	Part of the FunctionSuite class

y = sum(floor(x).^2, 2);

valid = not(any(isnan(y), 2));

end
