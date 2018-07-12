classdef WBpackage < handle
	%WBPACKAGE Packaging WBinstance for optimization runs
	%   Encapsulation for a WBinstance object in order to make running 
	%	optimization algorithms on them easier.
	%
	%	Use the following syntax for calling WBpackage.simulate() as an 
	%	anonymous function:
	%		@(x) WBpack.simulate(x, 'seek')
	
	properties (SetAccess = public, GetAccess = public) % Public read/write properties
		WBi					% WBinstance object
	end
	
	properties (SetAccess = private, GetAccess = public) % Public read-only properties
		inputSetBool			% Indicates if input indices have been set yet
		inputFuncSetBool		% Indicates if input function has been set yet
		outputSetBool			% Indicates if output indices have been set yet
		outputFuncSetBool		% Indicates if output function has been set yet

		inputInd				% Indices of input variables
		inputFunc				% Input function
		outputInd				% Indices of output variables
		outputFunc				% Output function
		validFunc				% Validity function
		inputInvFunc			% Inverse input function (used for initializing with previous points)

		lenInput				% Number of inputs (before input function, if applicable)
		lenOutput				% Number of outputs (after output function, if applicable)

		maxCallsPerSet			% Maximum calls per set sent to Workbench
		
		operatingPointInd		% Indices of operating point variables
		operatingPointValues	% Values used for operating point(s)
		nOperatingPoints		% Amount of operating points
	end
	
	methods
		function obj = WBpackage(projectFilePath, inputIDs, outputIDs, nInputs, nOutputs, inputFunc, outputFunc, validFunc, inputInvFunc)
		%WBPACKAGE WBPackage constructor method
			% Set optional inputs if not used
			if nargin < 9
				inputInvFunc = [];
				if nargin < 8
					validFunc = [];
					if nargin < 7
						outputFunc = [];
						if nargin < 6
							inputFunc = [];
							if nargin < 5
								nOutputs = length(outputIDs);
								if nargin < 4
									nInputs = length(inputIDs);
								end
							end
						end
					end
				end
			end

			% Create WBinstance
			obj.WBi = WBinstance(projectFilePath);

			% Set default parameters
			obj.inputSetBool = false;
			obj.inputFuncSetBool = false;
			obj.outputSetBool = false;
			obj.outputFuncSetBool = false;

			obj.inputInd = zeros(1,0);
			obj.inputFunc = [];
			obj.outputInd = zeros(1,0);
			obj.outputFunc = [];
			obj.validFunc = [];
			obj.inputInvFunc = [];

			obj.lenInput = 0;
			obj.lenOutput = 0;

			% Set parameters
			obj = obj.set_inputs(inputIDs, nInputs, inputFunc);
			obj = obj.set_outputs(outputIDs, nOutputs, outputFunc);
			
			% Set validity function (not used if empty)
			obj.validFunc = validFunc;
			
			% Set inverse input function if needed
			if ~isempty(inputInvFunc)
				obj.inputInvFunc = inputInvFunc;
			end

			obj.maxCallsPerSet = 50; % too long a script sent to WB causes a compiling error in ironPython, this limit prevents this
			
			% Set empty (default) operating point values
			obj.operatingPointInd = [];
			obj.operatingPointValues = [];
			obj.nOperatingPoints = 1;
		end
		
		% Public methods
		obj = set_inputs(obj, identifiers, nInputs, funcHandle);
		obj = set_outputs(obj, identifiers, nOutputs, funcHandle);
		obj = set_operating_points(obj, identifiers, values);
		[x, y, valid] = get_previous(obj, indices);
		[y, valid] = simulate(obj, x, runType);
		%y = read(obj, readInd);
		lenY = get_y_length(obj);
	end
end
