function [P, Yref, volume, Pind] = pareto_front_hypervolume(Y, Yref)
%PARETO_FRONT_HYPERVOLUME Calculates the pareto front's hypervolume from Y
%   Y		The dataset, each row is a data point
%	YREF	(optional) A reference point, bounding the back faces of the 
%			hypervolume. If empty or not given it is initialized with the
%			worst (highest) extent of Y.
%
%	Part of the MOSAO class.

if nargin < 2
	Yref = [];
end

% Get number of objectives
nObjectives = size(Y, 2);

% Create/correct Yref
if isempty(Yref) || (length(Yref) ~= nObjectives)
	Yref = max(Y, [], 1);
end

% Get pareto set
[P, Pind] = MOSAO.pareto_front(Y);

% Get hypervolume
volume = MOSAO.get_hypervolume(P, Yref);

end

