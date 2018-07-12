function [obj] = set_seek_input_parameter(obj, paramIndex)
%SET_SEEK_INPUT_PARAMETER Sets the input param index for the seek run-type
%	Static method for WBinstance class

tempIndex = obj.check_param_index(paramIndex);

if isempty(tempIndex)
	warning('ParamIndex not found, previous value left unchanged.');
else
	obj.seekInputParamInd = tempIndex;
end

end
