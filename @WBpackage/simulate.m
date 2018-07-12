function [y, valid] = simulate(obj, x, runType)
%SIMULATE Sets up and runs simulations in ANSYS Workbench
%
%	Part of the WBpackage class.

if nargin < 3
	runType = 'plain';
end

% Exit immediately if input or outputs are not defined
if ~obj.inputSetBool || ~obj.outputSetBool
	warning('WBpackage:ParamIndsNotSet', 'Input or output parameter indices are not yet set.');
	y = [];
	return;
end

% Check runType is valid
if ~any(strcmp(runType, {'plain', 'seek'}))
	error('WBpackage:UnrecognizedRunType', 'Unrecognized runType.');
end

% Check length of x
if size(x, 2) ~= obj.lenInput
	error('WBpackage:BadXLength', 'Length of x vectors do not match WBpackage.');
end
nDP = size(x, 1);

% Create empty output arrays
results = [];
simValid = [];
y = [];
valid = [];

% Use inputFunc if applicable
paramValues = zeros(nDP, length(obj.inputInd));
if obj.inputFuncSetBool
	for i = 1:nDP
		paramValues(i,:) = obj.inputFunc(x(i,:));
	end
else
	paramValues = x;
end

% Create ranges for sets of runs
maxDPsPerSet = max( ...
	floor(obj.maxCallsPerSet/obj.nOperatingPoints), ...
	obj.nOperatingPoints );
setStart = 1:maxDPsPerSet:nDP;
setEnd = min(nDP, setStart + maxDPsPerSet - 1);

% For each set of runs
for r = 1:length(setStart)
	% Create design points for each input vector
	iDP = zeros(setEnd(r) - setStart(r) + 1, obj.nOperatingPoints);
	for i = 1:(setEnd(r) - setStart(r) + 1)
		% Create DP's for each operating point
		for j = 1:obj.nOperatingPoints
			% Create DP
			if j==1
				% If first DP of operating point set, use initializeFrom DP
				[obj.WBi.designPoints, iDP(i,j)] = obj.WBi.designPoints.add_copy(obj.WBi.designPoints.initializeFrom);
			else
				% Otherwise, copy the first operating point DP
				[obj.WBi.designPoints, iDP(i,j)] = obj.WBi.designPoints.add_copy(iDP(i,1));
			end
			
			% Set operating point values
			for k = 1:length(obj.operatingPointInd)
				obj.WBi.designPoints = obj.WBi.designPoints.change_value( ...
					iDP(i,j), obj.operatingPointInd(k), obj.operatingPointValues(j,k) );
			end
			
			% Change input values
			for k = 1:size(paramValues, 2)
				obj.WBi.designPoints = obj.WBi.designPoints.change_value( ...
					iDP(i,j), obj.inputInd(k), paramValues(setStart(r) + i - 1, k));
			end
		end
	end
	
	% Reshape iDP to a column vector
	iDPreshape = reshape(iDP', [], 1);
	
	% Run geometry
	[obj.WBi, ~, validGeom] = obj.WBi.run_set(iDPreshape, 'geometry');

	% Run simulations
	switch runType
		case 'plain'
			[obj.WBi, ~, validSim] = obj.WBi.run_set(iDPreshape, 'simple');
		case 'seek'
			[obj.WBi, ~, validSim] = obj.WBi.run_set(iDPreshape, 'seek');
	end

	% Collect results
	for i = 1:(setEnd(r) - setStart(r) + 1)
		tempResults = obj.WBi.designPoints.data(iDP(i,:), obj.outputInd);
		tempValid = obj.WBi.designPoints.valid(iDP(i,:));
		
		% Use outputFunc if applicable
		if obj.outputFuncSetBool
			y = [y; obj.outputFunc(tempResults, tempValid)];
		else
			y = [y; tempResults];
		end
		
		% Use validFunc if applicable
		if ~isempty(obj.validFunc)
			valid = [valid; obj.validFunc(x, tempResults, tempValid)];
		else
			valid = [valid; all(tempValid)];
		end
	end
end

% Check size of y
if size(y, 2) ~= obj.lenOutput
	error('WBpackage:BadYLength', 'Length of y vectors do not match WBpackage.lenOutput.');
end
if size(y, 1) ~= nDP
	error('WBpackage:BadYamount', 'Number of y vectors does not match the number of x vectors.')
end

end
