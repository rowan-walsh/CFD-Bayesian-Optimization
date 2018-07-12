function [PoV] = classification_probability(X, model)
%CLASSIFICATION_PROBABILITY Returns probability of X being valid based on model

[~, tempProb] = predict(model, X);

PoV = tempProb(:, 2);

end
