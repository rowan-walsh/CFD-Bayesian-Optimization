function [y, valid] = function_simple_mo(x)
%FUNCTION_SIMPLE_MO  Simple MO test function, x is a row-wise list of vectors
%	From MATLAB example.
%	Part of the FunctionSuite class

y = [ (x(:,1)+2).^2 + (x(:,2)-3).^2 - 10, ...
	  (x(:,1)-2).^2 + (x(:,2)+1).^2 + 20 ];
  
valid = not(any(isnan(y), 2));

end
