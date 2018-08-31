function [meanPred] = mean_prediction(X, model)
%MEAN_PREDICTION Gets the mean prediction from the model(s)

if iscell(model)
	model = model{1};
end

if isa(model, 'struct')
	[y, ~] = predictor(X, model);
elseif isa(model, 'RegressionGP')
	[y, ~] = predict(model, X);
else
	error('Model type not recognized.');
end

meanPred = y;

end

