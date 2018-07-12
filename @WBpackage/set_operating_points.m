function obj = set_operating_points(obj, identifiers, values)
%SET_OPERATING_POINTS Sets the operating points of a WBpackage, if needed.
%
%	IDENTIFIERS	Vector of indices or cell-array of strings identifying what
%				parameters are used for changing the operating point of the
%				simulations.
%	VALUES		Array of values used for the operating points. Number of
%				columns must match the length of IDENTIFIERS. Each row
%				cooresponds to an operating point.
%
%	When a obj.simulate(x) is run, Workbench will be scripted to run a 
%	simulation at x for each currently defined operating point. If no
%	operating points have been defined (or obj.set_operating_point() was 
%	run with IDENTIFIERS and VALUES passed in empty), the simulation will 
%	only have a single run at x, with the operating conditions as defined 
%	in the current obj.WBi.designPoints.initializeFrom design point.
%
%	Part of the WBpackage class.

% Get operating point parameter indices
if isnumeric(identifiers)
	% Given numeric indices
	if any(identifiers > obj.WBi.designPoints.paramAmount)
		error('WBpackage:UnrecognizedOpParamIDs', 'Unrecognized operating point identifier number.');
	end
	tempInd = identifiers;
elseif iscell(identifiers)
	% Given strings to compare to parameter descriptions
	tempInd = zeros(1, length(identifiers));
	for i = 1:length(identifiers)
		temp = find(strcmp(identifiers(i), obj.WBi.designPoints.paramDescriptions), 1);
		if ~isempty(temp)
			tempInd(i) = temp;
		else
			error('WBpackage:UnrecognizedOpParamIDs', 'Unrecognized operating point identifier string.');
		end
	end
else
	error('WBpackage:UnrecognizedOpParamIDs', 'Unrecognized operating point identifier type.');
end

% Check operating point indices
if ~all(obj.WBi.designPoints.paramMutable(tempInd))
	error('WBpackage:ImmutableInputs', 'Immutable operating point parameter found.');
end

% Get and check lengths
nParam = length(tempInd);
nOpPoint = size(values, 1);
if nParam ~= size(values, 2)
	error('WBpackage:BadOpParamValueSize', 'Operating point values array width does not match the number of op. point parameters.');
end

% Set object properties
obj.operatingPointInd = tempInd;
obj.operatingPointValues = values;
if isempty(obj.operatingPointInd)
	obj.nOperatingPoints = 1;
else
	obj.nOperatingPoints = nOpPoint;
end

end

