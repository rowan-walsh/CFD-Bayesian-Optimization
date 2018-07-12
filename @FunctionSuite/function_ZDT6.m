function [y, valid] = function_ZDT6(x)
%FUNCTION_ZDT6 ZDT6 test function, x is a row-wise list of vectors
%	From E. Zitzler et al. (2000)
%	Part of the FunctionSuite class

m = size(x,2);

f1 = 1 - exp(-4*x(:,1)).*sin(6*pi*x(:,1)).^6;
g = 1 + 9*(sum(x(:,2:end), 2)/(m-1)).^0.25;
h = 1 - (f1./g).^2;

f2 = g.*h;
y = [f1, f2];

valid = not(any(isnan(y), 2));

end
