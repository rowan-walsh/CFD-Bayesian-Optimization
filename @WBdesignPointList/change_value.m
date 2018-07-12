function [obj] = change_value(obj, designPointIndex, paramIndex, value, retainValidity)
%change_value Changes the value of a design point's parameter
%	Part of the WBdesignPointList class

if nargin < 5
	retainValidity = false;
end

% Check input indexes
if designPointIndex > obj.amount
	error('Design point index is not valid for this list.')
end
if ischar(paramIndex) % Allows paramIndex to be a string ('P14', etc) of the param ID
	paramIndex = find(strcmp(obj.paramNames, paramIndex), 1);
	if isempty(paramIndex)
		error('Invalid text entry for paramIndex.')
	end
elseif paramIndex > obj.paramAmount
	error('Parameter index is not valid for this list.')
end

% Check that the parameter is set to mutable
if ~obj.paramMutable(paramIndex)
	error('Parameter to change is not mutable.')
end

% Change value
obj.data(designPointIndex, paramIndex) = value;

% Mark as needs-update
obj.needsUpdate(designPointIndex, paramIndex) = true;

% Mark as invalid, unless flagged to retain old value
if ~retainValidity
	obj.valid(designPointIndex) = false;
end

% Show warning about losing data if design point is not new
if ~obj.new(designPointIndex)
	warning('A parameter for a previously-updated design point was changed.\n\tThe current data for design point %i will be lost when updated.', designPointIndex)
end
	
end

