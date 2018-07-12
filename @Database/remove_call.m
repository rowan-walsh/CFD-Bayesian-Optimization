function [] = remove_call(obj, indices)
%REMOVE_CALL Removes the specified call(s) from the database
%
%	Part of the Database class.

if any(indices <= 0) || any(indices > obj.callAmount)
	error('Database:badInd', 'Invalid ind passed to remove_call()');
end

% Remove from database
obj.x(indices,:) = [];
obj.y(indices,:) = [];
obj.valid(indices) = [];
obj.call(indices) = [];
obj.callAmount = obj.callAmount - length(indices);

end
