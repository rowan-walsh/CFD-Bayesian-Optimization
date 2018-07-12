function [obj] = organize_run_outputs(obj, runningGenCallsList, genTimeList, nParetoList, HVList)
%ORGANIZE_RUN_OUTPUTS Organizes the outputs of a completed run
%
%	RUNNINGGENCALLSLIST
%		List of obj.db.callAmount values after each gen from the current
%		run.
%
%	GENTIMELIST
%		List of the time from each gen of the current run.
%
%	NPARETOLIST
%		List of number of pareto points from each gen of the current run.
%
%	HVLIST
%		List of the pareto hypervolume from each gen of the current run.
%
%	Part of the MOSAO class. Private method.

if nargin < 5
	HVList = [];
	if nargin < 4
		nParetoList = [];
	end
end

% Get final best y value(s)
if obj.db.lenY > 1 % Multi objective
	tempX = obj.db.x(obj.db.valid,:);
	tempY = obj.db.y(obj.db.valid,:);
	
	[P, tempFinalI] = MOSAO.pareto_front(tempY);
	obj.final.x = tempX(tempFinalI, :);
	obj.final.y = P;
	obj.final.ind = tempFinalI;
else % Single objective
	tempMin = min(obj.db.y(obj.db.valid));
	if isempty(tempMin) % No minimum (unlikely)
		obj.final.x = [];
		obj.final.y = [];
	else
		tempFinalI = find(obj.db.y == tempMin, 1, 'first');

		obj.final.x = obj.db.x(tempFinalI, :);
		obj.final.y = obj.db.y(tempFinalI);
		obj.final.ind = tempFinalI;
	end
end

obj.final.nCalls = obj.db.callAmount;
obj.final.nGens = length(obj.iter);

if isfield(obj.final, 'runningCallsGen')
	obj.final.runningCallsGen = [obj.final.runningCallsGen; runningGenCallsList]; 
else
	obj.final.runningCallsGen = runningGenCallsList;
end

if isfield(obj.final, 'timeGen')
	obj.final.timeGen = [obj.final.timeGen; genTimeList];
else
	obj.final.timeGen = genTimeList;
end

if ~isempty(nParetoList)
	if isfield(obj.final, 'nParetoGen')
		obj.final.nParetoGen = [obj.final.nParetoGen; nParetoList];
	else
		obj.final.nParetoGen = nParetoList;
	end
end

if ~isempty(HVList)
	if isfield(obj.final, 'HVGen')
		obj.final.HVGen = [obj.final.HVGen; HVList];
	else
		obj.final.HVGen = HVList;
	end
end

end

