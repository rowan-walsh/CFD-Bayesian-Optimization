function [PoI] = probability_of_improvement(X, model, fmin)
%PROBABILITY_OF_IMPROVEMENT Calculates probability of improvement of a model at X
%	Based on Jones et al. (2001), Eqn. (28)

if iscell(model)
	model = model{1};
end

if isa(model, 'struct')
	[y, ssq] = predictor(X, model);
	s = sqrt(ssq);
elseif isa(model, 'RegressionGP')
	[y, s] = predict(model, X);
else
	error('Model type not recognized.');
end

if nargin < 3
	fmin = min(y);
end

u = (fmin - y)./s;
PoI = normcdf(u);

end
