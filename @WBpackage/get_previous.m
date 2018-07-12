function [x, y, valid] = get_previous(obj, indices)
%GET_PREVIOUS Returns previous x and y values from WBinstance
%
%	INDICES:	(optional) Indices of design points to retrieve, not 
%				checked for validity. If not given, defaults to all design
%				points.
%
%	Part of the WBpackage class.

x = [];
y = [];
valid = [];

if nargin < 2
	indices = 1:obj.WBi.designPoints.amount;
end

% Requires inputInvFunc to be defined if an input function is used
if isempty(obj.inputInvFunc) && obj.inputFuncSetBool
	warning('WBpackage:noInputInvFunc', 'A valid inputInvFunc is required for get_previous().');
	return
end

% Check length of indices is a multiple of operating point DP amount
if mod(length(indices), obj.nOperatingPoints) ~= 0
	warning('WBpackage:BadIndicesAmount', 'Indices amount must be a multiple of the operating point amount.');
	return
end

% For each nOperatingPoints of indices
for i = 1:obj.nOperatingPoints:length(indices)
	iOP = i + (1:obj.nOperatingPoints) - 1;
	
	% Check that the values match the current operating point values
	if ~all(all(obj.WBi.designPoints.data(indices(iOP), obj.operatingPointInd) == obj.operatingPointValues))
		warning('WBpackage:BadOPvalues', 'Cannot get more previous values; unmatched operating point conditions found.');
		return
	end
	
	% Get data
	inputs = obj.WBi.designPoints.data(indices(iOP), obj.inputInd);
	results = obj.WBi.designPoints.data(indices(iOP), obj.outputInd);
	validSim = obj.WBi.designPoints.valid(indices(iOP));

	% Check all x values in the operating point set are identical
	if ~all(all(inputs == inputs(1,:)))
		warning('WBpackage:BadOPvalues', 'Cannot get more previous values; unmatching x values found in an operating point set.');
		return
	end
	
	% Calculate y, use outputFunc if applicable
	if obj.outputFuncSetBool
		y = [y; obj.outputFunc(results, validSim)];
	else
		y = [y; results];
	end

	% Calculate x, use inputInvFunc if applicable
	if obj.inputFuncSetBool
		x = [x; obj.inputInvFunc(inputs(1,:))];
	else
		x = [x; inputs(1,:)];
	end

	% Get valid, use validFunc if needed
	if ~isempty(obj.validFunc)
		valid = [valid; obj.validFunc(x, results, validSim)];
	else
		valid = [valid; obj.WBi.designPoints.valid(indices)];
	end
end

end

