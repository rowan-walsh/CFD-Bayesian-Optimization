classdef FunctionSuite
	%FunctionSuite Test function object
	%   Once initialized, stores information for a certain test function

	properties (SetAccess = private, GetAccess = public)
		% Public read-only properties
		name
		source
		LB
		UB
		func
		lenX
		lenY
		bestX
		bestY
		validLenX
		validLenY
	end
	
	properties (Constant, GetAccess = private)
		% Private constant properties
		types = { ...
			'sphere', ...
			'ellipsoid', ...
			'ackley', ...
			'griewank', ...
			'rastrigin', ...
			'rosenbrock', ...
			'sphere-bounded', ...
			'ellipsoid-bounded', ...
			'ackley-bounded', ...
			'griewank-bounded', ...
			'rastrigin-bounded', ...
			'rosenbrock-bounded', ...
			'g04', ...
			'g06', ...
			'simpleMO', ...
			'step', ...
			'ZDT1', ...
			'ZDT2', ...
			'ZDT3', ...
			'ZDT4', ...
			'ZDT6', ...
			};
	end
	
	methods
		% Class constructor method
		function obj = FunctionSuite(type, lenX, lenY)
			switch type
				case 'sphere'
					obj.name = 'Sphere';
					obj.source = '';
					obj.LB = -5.12*ones(1, lenX);
					obj.UB = 5.12*ones(1, lenX);
					obj.func = @(x) obj.function_sphere(x, false);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;
					
				case 'ellipsoid'
					obj.name = 'Ellipsoid';
					obj.source = '';
					obj.LB = -5.12*ones(1, lenX);
					obj.UB = 5.12*ones(1, lenX);
					obj.func = @(x) obj.function_ellipsoid(x, false);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;

				case 'ackley'
					obj.name = 'Ackley';
					obj.source = '';
					obj.LB = -32.768*ones(1, lenX);
					obj.UB = 32.768*ones(1, lenX);
					obj.func = @(x) obj.function_ackley(x, false);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;
				
				case 'griewank'
					obj.name = 'Griewank';
					obj.source = '';
					obj.LB = -600*ones(1, lenX);
					obj.UB = 600*ones(1, lenX);
					obj.func = @(x) obj.function_griewank(x, false);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;
				
				case 'rastrigin'
					obj.name = 'Rastrigin';
					obj.source = '';
					obj.LB = -5.12*ones(1, lenX);
					obj.UB = 5.12*ones(1, lenX);
					obj.func = @(x) obj.function_rastrigin(x, false);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;
				
				case 'rosenbrock'
					obj.name = 'Rosenbrock';
					obj.source = '';
					obj.LB = -2.048*ones(1, lenX);
					obj.UB = 2.048*ones(1, lenX);
					obj.func = @(x) obj.function_rosenbrock(x, false);
					obj.bestX = ones(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;

				case 'sphere-bounded'
					obj.name = 'Bounded-Sphere';
					obj.source = '';
					obj.LB = -5.12*ones(1, lenX);
					obj.UB = 5.12*ones(1, lenX);
					obj.func = @(x) obj.function_sphere(x, true);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;
					
				case 'ellipsoid-bounded'
					obj.name = 'Bounded-Ellipsoid';
					obj.source = '';
					obj.LB = -5.12*ones(1, lenX);
					obj.UB = 5.12*ones(1, lenX);
					obj.func = @(x) obj.function_ellipsoid(x, true);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;

				case 'ackley-bounded'
					obj.name = 'Bounded-Ackley';
					obj.source = '';
					obj.LB = -32.768*ones(1, lenX);
					obj.UB = 32.768*ones(1, lenX);
					obj.func = @(x) obj.function_ackley(x, true);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;
				
				case 'griewank-bounded'
					obj.name = 'Bounded-Griewank';
					obj.source = '';
					obj.LB = -600*ones(1, lenX);
					obj.UB = 600*ones(1, lenX);
					obj.func = @(x) obj.function_griewank(x, true);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;
				
				case 'rastrigin-bounded'
					obj.name = 'Bounded-Rastrigin';
					obj.source = '';
					obj.LB = -5.12*ones(1, lenX);
					obj.UB = 5.12*ones(1, lenX);
					obj.func = @(x) obj.function_rastrigin(x, true);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;
				
				case 'rosenbrock-bounded'
					obj.name = 'Bounded-Rosenbrock';
					obj.source = '';
					obj.LB = -2.048*ones(1, lenX);
					obj.UB = 2.048*ones(1, lenX);
					obj.func = @(x) obj.function_rosenbrock(x, true);
					obj.bestX = ones(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;

				case 'g04'
					obj.name = 'g04';
					obj.source = 'T. Runarsson et al. (2000)';
					obj.LB = [ 78, 33, 27, 27, 27];
					obj.UB = [102, 45, 45, 45, 45];
					obj.func = @(x) obj.function_g04(x);
					obj.bestX = [78, 33, 29.995256025682, 45, 36.775812905788];
					obj.bestY = -30665.539;
					validLenX = 5;
					validLenY = 1;
					
				case 'g06'
					obj.name = 'g06';
					obj.source = 'T. Runarsson et al. (2000)';
					obj.LB = [13, 0];
					obj.UB = [100, 100];
					obj.func = @(x) obj.function_g06(x);
					obj.bestX = [14.095, 0.84296];
					obj.bestY = -6961.81388;
					validLenX = 2;
					validLenY = 1;
					
				case 'simpleMO'
					obj.name = 'Simple MO';
					obj.source = 'MATLAB MO example';
					obj.LB = -10*ones(1, lenX);
					obj.UB = 10*ones(1, lenX);
					obj.func = @(x) obj.function_simple_mo(x);
					obj.bestX = 0;
					obj.bestY = 0;
					validLenX = 2;
					validLenY = 2;
					
				case 'step'
					obj.name = 'Step';
					obj.source = '';
					obj.LB = -5.12*ones(1, lenX);
					obj.UB = 5.12*ones(1, lenX);
					obj.func = @(x) obj.function_step(x);
					obj.bestX = zeros(1, lenX);
					obj.bestY = 0;
					validLenX = []; % empty means all
					validLenY = 1;
					
				case 'ZDT1'
					obj.name = 'Zitzler–Deb–Thiele N. 1';
					obj.source = 'E. Zitzler et al. (2000)';
					obj.LB = 0*ones(1, lenX);
					obj.UB = 1*ones(1, lenX);
					obj.func = @(x) obj.function_ZDT1(x);
					obj.bestX = @(t) [t, zeros(1,29)];
					obj.bestY = @(t) [t, 1 - sqrt(t)];
					validLenX = []; % empty means all
					validLenY = 2;

				case 'ZDT2'
					obj.name = 'Zitzler–Deb–Thiele N. 2';
					obj.source = 'E. Zitzler et al. (2000)';
					obj.LB = 0*ones(1, lenX);
					obj.UB = 1*ones(1, lenX);
					obj.func = @(x) obj.function_ZDT2(x);
					obj.bestX = @(t) [t, zeros(1,29)];
					obj.bestY = @(t) [t, 1 - t.^2];
					validLenX = []; % empty means all
					validLenY = 2;
					
				case 'ZDT3'
					obj.name = 'Zitzler–Deb–Thiele N. 3';
					obj.source = 'E. Zitzler et al. (2000)';
					obj.LB = 0*ones(1, lenX);
					obj.UB = 1*ones(1, lenX);
					obj.func = @(x) obj.function_ZDT3(x);
					obj.bestX = @(t) [t, zeros(1,29)];
					obj.bestY = @(t) [t, 1 - sqrt(t) - t.*sin(10*pi*t)];
					validLenX = []; % empty means all
					validLenY = 2;
					
				case 'ZDT4'
					obj.name = 'Zitzler–Deb–Thiele N. 4';
					obj.source = 'E. Zitzler et al. (2000)';
					obj.LB = [0, -5*ones(1, lenX-1)];
					obj.UB = [1, 5*ones(1, lenX-1)];
					obj.func = @(x) obj.function_ZDT4(x);
					obj.bestX = @(t) [t, zeros(1,9)];
					obj.bestY = @(t) [t, 1 - sqrt(t)];
					validLenX = []; % empty means all
					validLenY = 2;
					
				case 'ZDT6'
					obj.name = 'Zitzler–Deb–Thiele N. 6';
					obj.source = 'E. Zitzler et al. (2000)';
					obj.LB = 0*ones(1, lenX);
					obj.UB = 1*ones(1, lenX);
					obj.func = @(x) obj.function_ZDT6(x);
					obj.bestX = @(t) [t, zeros(1,9)];
					obj.bestY = @(t) [1 - exp(-4*t).*sin(6*pi*t).^6, 1 - (1 - exp(-4*t).*sin(6*pi*t).^6).^2];
					validLenX = []; % empty means all
					validLenY = 2;
					
				otherwise
					error('FunctionSuite:UnrecognizedFunction', 'Unrecognized function TYPE');
			end
			
			% If lenX or lenY are empty, set as defaults
			if isempty(lenX)
				if isempty(validLenX)
					lenX = 2;
				else
					lenX = validLenX(1);
				end
			end
			
			if isempty(lenY)
				if isempty(validLenY)
					lenY = 2;
				else
					lenY = validLenY(1);
				end	
			end
			
			% Check variable amounts are okay
			if isempty(validLenX) || any(lenX == validLenX)
				obj.lenX = lenX;
			else
				error('FunctionSuite:BadLenX', 'lenX is not valid for function type %s', type);
			end
			
			if isempty(validLenY) || any(lenY == validLenY)
				obj.lenY = lenY;
			else
				error('FunctionSuite:BadLenY', 'lenY is not valid for function type %s', type);
			end
			
			obj.validLenX = validLenX;
			obj.validLenY = validLenY;
		end
		
		% Public methods (none)
	end
	
	methods(Static = true) % Static methods
		[functions] = list_functions();
		
		[y, valid] = function_sphere(x, bounded);
		[y, valid] = function_ellipsoid(x, bounded);
		[y, valid] = function_g04(x);
		[y, valid] = function_g06(x);
		[y, valid] = function_ackley(x, bounded);
		[y, valid] = function_griewank(x, bounded);
		[y, valid] = function_rastrigin(x, bounded);
		[y, valid] = function_rosenbrock(x, bounded);
		[y, valid] = function_simple_mo(x)
		[y, valid] = function_step(x)
		[y, valid] = function_ZDT1(x)
		[y, valid] = function_ZDT2(x)
		[y, valid] = function_ZDT3(x)
		[y, valid] = function_ZDT4(x)
		[y, valid] = function_ZDT6(x)
	end	
end