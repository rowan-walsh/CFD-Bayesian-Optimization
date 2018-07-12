function [obj] = set_seek_output_parameter(obj, paramIndex)
%SET_SEEK_OUTPUT_PARAMETER Sets the output param index for the seek run-type
%	Method for WBinstance class

tempIndex = obj.check_param_index(paramIndex);

if isempty(tempIndex)
	warning('ParamIndex not found, previous value left unchanged.');
else
	obj.seekOutputParamInd = tempIndex;
end

end
