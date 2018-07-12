function [y, valid] = function_g06(x)
%FUNCTION_G06  G06 test function, x is a row-wise list of vectors
%	From T. Runarsson et al. (2000)
%	Part of the FunctionSuite class

y = (x(:,1) - 10).^3 + (x(:,2) - 20).^3;

valid = not(any(isnan(y), 2));
g1valid = (-(x(:,1) - 5).^2 - (x(:,2) - 5).^2 + 100) <= 0;
g2valid = ((x(:,1) - 6).^2 + (x(:,2) - 5).^2 - 82.81) <= 0;

valid = valid & g1valid & g2valid;

end
