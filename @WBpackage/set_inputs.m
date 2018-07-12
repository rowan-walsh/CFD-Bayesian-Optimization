function [obj] = set_inputs(obj, identifiers, nInputs, funcHandle)
%SET_INPUTS Sets indices of input variables and optional input function
%
%	IDENTIFIERS	Vector of indices for inputs or cell array of input 
%				variable names.
%	NINPUTS		Length of inputs to funcHandle, if no funcHandle given, 
%				defaults to the length of IDENTIFIERS.
%	FUNCHANDLE	Optional function handle to apply before inputs are sent to 
%				the simulation. Must return a matrix with the same number
%				of columns as indices in IDENTIFIERS.
%
%	Part of the WBpackage class.

if nargin < 4
	funcHandle = [];
	nInputs = length(identifiers);
end

% Get input indices
if isnumeric(identifiers)
	% Given numeric indices
	if any(identifiers > obj.WBi.designPoints.paramAmount)
		error('WBpackage:UnrecognizedInputIDs', 'Unrecognized input identifier number.');
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
			error('WBpackage:UnrecognizedInputIDs', 'Unrecognized input identifier string.');
		end
	end
else
	error('WBpackage:UnrecognizedInputIDs', 'Unrecognized input identifier type.');
end

% Check input indices
if all(obj.WBi.designPoints.paramMutable(tempInd))
	% If all are mutable, proceed to set indices
	obj.inputInd = tempInd;
else
	error('WBpackage:ImmutableInputs', 'Immutable input parameter found.');
end

% Set input function and input length
obj.inputFunc = funcHandle;
obj.inputFuncSetBool = ~isempty(funcHandle);
obj.lenInput = nInputs;

% Set input bool
obj.inputSetBool = true;

end
