function [functions] = list_functions()
%LIST_FUNCTIONS Prints a list of all available functions from FunctionSuite
%	Part of the FunctionSuite class

n = length(FunctionSuite.types);

data = cell(n, 4);

for i = 1:n
	tempTF = FunctionSuite(FunctionSuite.types{i}, [], []);
	
	% Get name
	data{i,1} = tempTF.name;
	
	% Get default lenX
	if isempty(tempTF.validLenX)
		data{i,2} = 'any';
	else
		data{i,2} = tempTF.lenX;
	end
	
	% Get default lenY
	if isempty(tempTF.validLenY)
		data{i,3} = 'any';
	else
		data{i,3} = tempTF.lenY;
	end
	
	% Get bestY
	data{i,4} = tempTF.bestY;
end

functions = cell2table(data, 'VariableNames', {'Name', 'lenX', 'lenY', 'bestY'});

end
