function [obj] = set_outputs(obj, identifiers, nOutputs, funcHandle)
%SET_OUTPUTS Sets indices of output variables and optional output function
%
%	IDENTIFIERS	Vector of indices for outputs or cell array of output 
%				variable names.
%	NOUTPUTS	Length of outputs from funcHandle, if no funcHandle given, 
%				defaults to the length of IDENTIFIERS.
%	FUNCHANDLE	Optional function handle to apply after outputs are 
%				obtained from the simulation. Takes as input (1) a matrix 
%				with the same number of columns as indices in IDENTIFIERS
%				where each row is the results from a different operating 
%				point, and (2) a boolean vector indicating valid result 
%				rows.
%
%	Part of the WBpackage class.

if nargin < 4
	funcHandle = [];
	nOutputs = length(identifiers);
end

% Get output indices
if isnumeric(identifiers)
	% Given numeric indices
	if any(identifiers > obj.WBi.designPoints.paramAmount)
		error('WBpackage:UnrecognizedOutputIDs', 'Unrecognized output identifier number.');
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
			error('WBpackage:UnrecognizedOutputIDs', 'Unrecognized output identifier string.');
		end
	end
else
	error('WBpackage:UnrecognizedOutputIDs', 'Unrecognized output identifier type.');
end

% Set output indices
obj.outputInd = tempInd;

% Set output function and output length
obj.outputFunc = funcHandle;
obj.outputFuncSetBool = ~isempty(funcHandle);
obj.lenOutput = nOutputs;

% Set output bool
obj.outputSetBool = true;

end
