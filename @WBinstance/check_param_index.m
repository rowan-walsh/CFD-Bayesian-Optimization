function [index] = check_param_index(obj, identifier)
%CEHCK_PARAM_INDEX Finds a param index based on identifier
%   IDENTIFIER	Can be a string or a numeric index
%
%	INDEX		Returns numeric index of found param index, if valid.
%				Returns [] if the index is not valid/found.

if isnumeric(identifier)
	% Numeric input
	if identifier <= 0 || identifier > obj.designPoints.paramAmount
		tempIndex = [];
	else % Valid index
		tempIndex = identifier;
	end
elseif ischar(identifier)
	% String input
	tempIndex = find(strcmp(identifier, obj.designPoints.paramDescriptions), 1);
else
	% Unrecognized input
	error('ParamIndex type not recognized.');
end

index = tempIndex;

end
