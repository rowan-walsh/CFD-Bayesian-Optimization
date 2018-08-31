function [EI] = expected_improvement(X, model, fmin)
%EXPECTED_IMPROVEMENT Calculates expected improvement of a model at X
%	Based on Jones et al. (2001), Eqn. (35)

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
EI = s.*(u.*normcdf(u) + normpdf(u));

end
