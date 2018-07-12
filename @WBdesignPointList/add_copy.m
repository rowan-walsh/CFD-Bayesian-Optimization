function [obj, newDesignPointIndex] = add_copy(obj, copyDesignPointIndex)
%add_copy Adds a copy of a current design point to the design point list
%	Part of the WBdesignPointList class

% Check input index
if copyDesignPointIndex > obj.amount
	error('Design point index to copy is not valid for this list.')
end

% Fill in copied design point
obj.data = [obj.data; obj.data(copyDesignPointIndex,:)];
obj.new = [obj.new; true];
obj.needsUpdate = [obj.needsUpdate; obj.needsUpdate(copyDesignPointIndex,:)];
obj.valid = [obj.valid; obj.valid(copyDesignPointIndex)];

% Unique name will be set once Workbench results are imported
obj.names = [obj.names; cell(1)];

obj.amount = obj.amount + 1;

% Pass index of copied design point
newDesignPointIndex = obj.amount;

end

