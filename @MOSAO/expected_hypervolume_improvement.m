function [EHVI] = expected_hypervolume_improvement(P, Yref, HVprev, models, Xnew)
%EXPECTED_HYPERVOLUME_IMPROVEMENT Expected improvement of hypervolume
%   Expected improvement of the hypervolume for Ynew = model_func(Xnew).
%   Uses a Monte Carlo integral approximation, error scales with 1/sqrt(N)
%
%	P		Set of current pareto points.
%	MODELS	Cell array of gaussian regression models, one for each
%			objective (Y) dimension.
%	Yref	The reference point for the upper bounds of the hypervolume.
%	XNEW	Point(s), row-wise, to have the probability calculated at.
%
%	Part of the MOSAO class.

nObjectives = length(models);
nPoints = size(Xnew, 1);
y = zeros(nPoints, nObjectives);
s = zeros(nPoints, nObjectives);
EHVI = zeros(nPoints, 1);

N = 10000;

for j = 1:nObjectives
	[y(:,j), s(:,j)]  = predict(models{j}, Xnew);
end

% Monte Carlo integration
for i = 1:nPoints
	sum = 0;
	
	% Create random test point samples
	Ytest = normrnd(repmat(y(i,:), 1, 1, N), repmat(s(i,:), 1, 1, N));
	
	% Check if P dominates the new point
	YtestIsDominated = any(all(Ytest >= P, 2), 1);
		
	for k = 1:N
		% Get change in hypervolume
		if ~YtestIsDominated(k)
			HVnew = MOSAO.get_hypervolume([P; Ytest(1,:,k)], Yref);
			sum = sum + (HVnew - HVprev);
		end
	end
	EHVI(i) = sum / N;
end


end
