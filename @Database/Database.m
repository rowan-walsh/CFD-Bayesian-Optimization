classdef Database < handle
	%DATABASE This class tracks the calls and results from a function

	properties % Public
	end
	properties (SetAccess = private, GetAccess = public)
		callAmount	% Number of function calls
		lenX		% Number of inputs
		lenY		% Number of outputs
		x			% List of called X values (row-wise)
		y			% List of resulting Y values (row-wise)
		valid		% List of resulting Y value validity (bools)
		call		% Tracks what call-set each value was part of
		LB			% Lower bounds for X values
		UB			% Upper bounds for X values
	end
	properties (SetAccess = private, GetAccess = private)
		currentCall
		fHandle
	end
	methods
		function obj = Database(functionHandle, lengthX, lengthY, lowerBound, upperBound)
		%DATABASE Class constructor for Database
			
			% Transpose bounds if needed
			if size(lowerBound, 1) ~= 1
				lowerBound = transpose(lowerBound);
			end
			if size(upperBound, 1) ~= 1
				upperBound = transpose(upperBound);
			end
			
			% Check size of bounds
			if (size(lowerBound, 2) ~= lengthX) || (size(lowerBound, 1) ~= 1)
				error('lowerBound must be a vector with length = lengthX');
			end
			if (size(upperBound, 2) ~= lengthX) || (size(upperBound, 1) ~= 1)
				error('upperBound must be a vector with length = lengthX');
			end
			
			% Check bounds do not overlap
			if any(lowerBound > upperBound)
				error('Some lowerBounds are greater than upperBound');
			end				
			
			% Set parameters
			obj.callAmount = 0;

			obj.lenX = lengthX;
			obj.lenY = lengthY;

			obj.x = zeros(0, obj.lenX);
			obj.y = zeros(0, obj.lenY);
			obj.valid = true(0, 1);
			obj.call = zeros(0, 1);

			obj.LB = lowerBound;
			obj.UB = upperBound;

			obj.currentCall = 0;
			obj.fHandle = functionHandle;
		end

		% Public methods
		[obj, iCalled] = call_function(obj, kx);
		[isValid] = check_bounds(obj, kx);
		[iExists] = check_existence(obj, kx);
		[iNeighbors] = nearest_neighbors(obj, kx, n, validOnly);
		[obj, iNew] = add_new(obj, kx, ky, kvalid);
		[] = remove_call(obj, indices);
	end
end