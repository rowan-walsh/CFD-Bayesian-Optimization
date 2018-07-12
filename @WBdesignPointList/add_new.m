function [obj, newDesignPointIndex] = add_new(obj, newDesignPointData)
%add_new Adds a new design-point to the list, filled with the passed data
%	Part of the WBdesignPointList class

% Check input array size
if all(size(newDesignPointData) ~= [obj.paramAmount, 1])
	error('Size of newDesignPointData does not match the number of parameters for this list.')
end

% Fill in new design point
obj.data = [obj.data; newDesignPointData'];
obj.new = [obj.new; true];
obj.needsUpdate = [obj.needsUpdate; true(1, obj.paramAmount)];
obj.valid = [obj.valid; false];

% Unique name will be set once Workbench results are imported
obj.names = [obj.names; cell(1)];

obj.amount = obj.amount + 1;

% Pass index of new design point
newDesignPointIndex = obj.amount;

end

