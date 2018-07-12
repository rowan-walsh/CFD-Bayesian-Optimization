function [y] = get_2D_summary_attainment_surface(Pset, Yref, method, nSamples)
%GET_2D_SUMMARY_ATTAINMENT_SURFACE 
%	PSET		Cell array of pareto sets
%	YREF		Reference point
%	METHOD		Method for obtaining the summary attainment surface:
%					'mean' average of points along each sample line
%					'median' median of points along each sample line
%					'best' best Pareto points
%					'worst' worst Pareto points, bounded by Yref
%	NSAMPLES	Number of sample lines to use	
%	
%	Part of the MOSAO class.

if nargin < 4
	nSamples = 1000;
end

nRuns = length(Pset);

% Check for 2D data
for i = 1:nRuns
	if size(Pset{i}, 2) ~= 2
		error('Non-2D Pareto set passed to 2D summary attainment surface function.');
	end
end

% Set surface summary method
switch method
	case 'mean'
		selectionFunc = @(u) mean(u);
	case 'median'
		selectionFunc = @(u) median(u);
	case 'best'
		selectionFunc = @(u) min(u);
	case 'worst'
		selectionFunc = @(u) max(u);
	otherwise
		error('Unrecognized summary attainment surface method.');
end

% Sort and bound Psets
Psb = cell(nRuns, 1);
for i = 1:nRuns
	tempP = sortrows(Pset{i}, 1);
	Psb{i} = tempP(and(tempP(:,1) < Yref(1), tempP(:,2) < Yref(2)), :);
end

% Get sample locations
lowerSampleEdge = Inf;
for i = 1:nRuns
	lowerSampleEdge = min([Psb{i}(:,1); lowerSampleEdge]);
end
samples = linspace(lowerSampleEdge, Yref(1), nSamples-1)';
summary = zeros(1, nSamples-1);

for j = 1:(nSamples-1)
	intersections = zeros(1, nRuns);
	for i = 1:nRuns
		tempInd = find(Psb{i}(:,1) <= samples(j), 1, 'last');
		if isempty(tempInd)
			intersections(i) = Yref(2);
		else
			intersections(i) = Psb{i}(tempInd, 2);
		end
	end
	summary(j) = selectionFunc(intersections);
end

y = zeros(nSamples-1, 2);
y(:,2) = summary;
y(:,1) = samples;

%y = [[Yref(1), y(1,2)]; y];
y = [[y(1,1), Yref(2)]; y];

end
