function [PoPI] = probability_of_pareto_improvement(P, models, Xnew)
%PROBABILITY_OF_PARETO_IMPROVEMENT Probability of improving pareto front P
%   Probability of Ynew = model_func(Xnew) being an improvement (new
%   dominant point) on the current pareto front P.
%	PoHVI = Prob_net = 1 - product(1 - Prob_i)
%
%	P		Set of current pareto points.
%	MODELS	Cell array of gaussian regression models, one for each
%			objective (Y) dimension.
%	XNEW	Point(s), row-wise, to have the probability calculated at.
%
%	Part of the MOSAO class.

nObjectives = length(models);
nPoints = size(Xnew, 1);
y = zeros(nPoints, nObjectives);
s = zeros(nPoints, nObjectives);
PoPI = zeros(nPoints, 1);

for i = 1:nObjectives
	[y(:,i), s(:,i)]  = predict(models{i}, Xnew);
end

for j = 1:nPoints
	PoPI(j) = 1 - MOSAO.get_dominated_probability(P, y(j,:), s(j,:));
end

end
