function [y] = get_2D_attainment_points(P, Yref)
%GET_2D_ATTAINMENT_POINTS Gets attainment line points from Pareto set.
%   Part of the MOSAO class.

Psorted = sortrows(P, [1, 2]);

% Check for a valid Pareto set a this point
if ~(issorted(Psorted(:,1)) && issorted(flip(Psorted(:,2))))
	error('MOSAO:BadParetoSet', 'P set does not appear to be a Pareto set.');
end

% Bound the output with Yref
inBounds = and(Psorted(:,1) < Yref(1), Psorted(:,2) < Yref(2));
Psorted = Psorted(inBounds,:);

% Create attainment line points, return empty if no P is in bounds
if isempty(Psorted)
	y = [];
else
	y = [[repelem(Psorted(:,1), 2, 1); Yref(1)], ...
		 [Yref(2); repelem(Psorted(:,2), 2, 1)]];
end

end
