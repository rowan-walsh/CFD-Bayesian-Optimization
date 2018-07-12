function [obj] = set_iterations_parameter(obj, paramIndex)
%SET_ITERATIONS_PARAMETER Sets the iterations param index for the seek run-type
%	Method for WBinstance class

tempIndex = obj.check_param_index(paramIndex);

if isempty(tempIndex)
	warning('ParamIndex not found, previous value left unchanged.');
else
	obj.iterationsParamInd = tempIndex;
end

end
