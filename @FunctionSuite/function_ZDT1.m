function [y, valid] = function_ZDT1(x)
%FUNCTION_ZDT1 ZDT1 test function, x is a row-wise list of vectors
%	From E. Zitzler et al. (2000)
%	Part of the FunctionSuite class

m = size(x,2);

f1 = x(:,1);
g = 1 + 9/(m-1)*sum(x(:,2:end), 2);
h = 1 - sqrt(f1./g);

f2 = g.*h;
y = [f1, f2];

valid = not(any(isnan(y), 2));

end
