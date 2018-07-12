function [obj] = set_seek_polynomial(obj, polyVector)
%SET_SEEK_POLYNOMIAL Sets the seek polynomal for WBinstance class
%	'polyVector' should be a vector containing the coefficiencts of a
%	polynomial, from 0-th to n-th power:
%		a*x^2 + b*x + c  -->  polyVector = [c b a]
%	Static method for WBinstance class

% Transpose vector if needed (probably not necessary)
if size(polyVector, 1) > size(polyVector, 2)
	polyVector = transpose(polyVector);
end

% Check all values in the vector are not complex
if ~all(isreal(polyVector))
	warning('Seek polynomial vector to set contains imaginary values.\nPrevious value left unchanged.');
	return
end

% Set WBinstance property
obj.seekPolynomial = polyVector;

end

