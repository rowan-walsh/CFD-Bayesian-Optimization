function [change] = change_of_hypervolume(P, Yref, HVprev, models, Xnew, type)
%CHANGE_OF_HYPERVOLUME Gets change in hypervolume of (Y+Ynew) vs (Y).
%	P		The pareto set
%	Yref	The reference point for the upper bounds of the hypervolume.
%	HVprev	The previous pareto hypervolume.
%	Ynew	The new data point
%	type	The type of Y data to use from the model for Xnew:
%				'meanValue'	Mean value returned by the model
%				'LCB'		Lower confidence bound returned by the model:
%							y_test = y - w*s
%
%	Part of the MOSAO class.

if nargin < 6
	type = 'meanValue';
end

% Get Ynew from Xnew and model(s)
nObj = size(Yref, 2);
Ytest = zeros(1, nObj);
switch type
	case 'meanValue'
		for i = 1:nObj
			Ytest(i) = predict(models{i}, Xnew);
		end
	case 'LCB'
		w = 1.5;
		for i = 1:nObj
			[y, s] = predict(models{i}, Xnew);
			Ytest(i) = y - w*s;
		end
	otherwise
		error('MOSAO:InvalidHVChangeType', 'Invalid hypervolume change type was used.');
end

% Check if P dominates the new point
YtestIsDominated = any(all(bsxfun(@ge, Ytest, P), 2));

% Get change in hypervolume
if YtestIsDominated
	change = 0;
else
	HVnew = MOSAO.get_hypervolume([P; Ytest], Yref);
	change = HVnew - HVprev;
end

end

