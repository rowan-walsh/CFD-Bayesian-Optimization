function [obj, X, data] = local_search(obj, initialX)
%LOCAL_SEARCH Performs a local search at initialX
%   INITIALX:	Local search start point.
%
%	Returns the locally-improved result X. If X has not been improved,
%	returns an empty X.
%
%	Part of the MOSAO class.

% Check x0 for size and bounds
if ~all(obj.db.check_bounds(initialX)) || size(initialX, 1) ~= 1
	error('MOSAO:BadInitialX', 'initialX violates the bounds or is not the right length.');
end

% Define radial basis function
switch obj.opt.LSrbf
	case 'linear'
		rbfFunc = @(r) RBF_linear(r);
	case 'gaussian'
		rbfFunc = @(r) RBF_gaussian(r);
	case 'thinplatespline'
		rbfFunc = @(r) RBF_thinPlateSpline(r);
	case 'cubicspline'
		rbfFunc = @(r) RBF_cubicSpline(r);
	otherwise
		error('MOSAO:UnrecognizedLSrbf', 'Unrecognized MOSAO.opt.LSrbf');
end

%% Main loop

% Define initial values
options = optimoptions('fmincon', ...
	'Algorithm', 'interior-point', ... % 'sqp' or 'interior-point'
	'Display', 'none' ); % 'iter-detailed' or 'none'

% Get nearest neighbors
nModel = min(obj.opt.LSmodelPoints, obj.db.callAmount);
data(1).iNear = obj.db.nearest_neighbors(initialX, nModel, obj.opt.LSuseValidOnly);

data(1).xC = initialX;
data(1).trustLB = 0.5*(min(obj.db.x(data(1).iNear, :), [], 1) - data(1).xC); %TBV
data(1).trustUB = 0.5*(max(obj.db.x(data(1).iNear, :), [], 1) - data(1).xC); %TBV

[obj.db, iTemp] = obj.db.call_function(data(1).xC);
data(1).yCExact = obj.db.y(iTemp);
data(1).iNear = [data(1).iNear; iTemp];

for j = 1:obj.opt.LSmaxRounds
	% Create local model
	data(j).model = fit_rbf_model( ...
		obj.db.x(data(j).iNear, :), obj.db.y(data(j).iNear), ...
		obj.db.UB - obj.db.LB, rbfFunc, obj.opt.LSbasis);
	
	% Run local optimization
	[data(j).dx, data(j).yLo] = fmincon( ...
		@(dx) predict_rbf_model(data(j).xC + dx, data(j).model), ...
		zeros(1, obj.db.lenX), ... % x0
		[], [], [], [], ... % A, B, Aeq, Beq
		data(j).trustLB, data(j).trustUB, ... % bounds
		[], ... % NONLCON
		options); % options
	
	% Check for uniqueness
	if norm(data(j).dx, 2) < 1e-10
		data(j).merit = 0;
	else
		% Do exact evaluation of local solution, add to local model dataset
		[obj.db, iTemp] = obj.db.call_function(data(j).xC + data(j).dx);
		data(j).yLoExact = obj.db.y(iTemp);
		data(j).iNear = [data(j).iNear; iTemp];
		
		% Calculate data(j).merit
		data(j).merit = (data(j).yCExact - data(j).yLoExact) / ...
			(predict_rbf_model(data(j).xC, data(j).model) - data(j).yLo);
	end
	
	% Set trust bounds based on data(j-1).merit
	if data(j).merit <= 0.25
		data(j+1).trustLB = 0.25*data(j).trustLB;
		data(j+1).trustUB = 0.25*data(j).trustUB;
	elseif data(j).merit <= 0.75
		data(j+1).trustLB = data(j).trustLB;
		data(j+1).trustUB = data(j).trustUB;
	else % data(j-1).merit > 0.75
		if any(data(j).dx == data(j).trustLB) || any(data(j).dx == data(j).trustUB)
			tempEps = 1;
		else
			tempEps = 2;
		end
		data(j+1).trustLB = tempEps*data(j).trustLB;
		data(j+1).trustUB = tempEps*data(j).trustUB;
	end

	% Set data(j+1).xC based on data(j).merit
	if data(j).merit > 0
		 data(j+1).xC =  data(j).xC + data(j).dx;
		 data(j+1).yCExact = data(j).yLoExact;
	else % data(j).merit <= 0
		 data(j+1).xC =  data(j).xC;
		 data(j+1).yCExact = data(j).yCExact;
	end
	
	% Cap trust bounds at overall bounds
	data(j+1).trustLB = max([data(j+1).trustLB; obj.db.LB - data(j+1).xC], [], 1);
	data(j+1).trustUB = min([data(j+1).trustUB; obj.db.UB - data(j+1).xC], [], 1);
	
	% Update nearest neighbors
	data(j+1).iNear = data(j).iNear;
	
end

% Set output based on whether improvement was observed
if data(obj.opt.LSmaxRounds + 1).yCExact < data(1).yCExact
	X = data(obj.opt.LSmaxRounds + 1).xC;
else
	X = [];
end

end

function [model] = fit_rbf_model(x, y, scale, hRBF, pOrder)
% Fits current RBF model to data (no data checking)

model.scale = scale;
model.Xt = x ./ model.scale;
model.Yt = y;
model.nX = size(model.Xt, 1);
model.nVar = size(model.Xt, 2);

model.RBF = hRBF;
model.pOrder = pOrder;

Phi = zeros(model.nX, model.nX);
for i = 1:model.nX
	for j = i+1:model.nX
		Phi(i,j) = model.RBF(norm(model.Xt(i,:) - model.Xt(j,:), 2));
		Phi(j,i) = Phi(i,j);
	end
end

switch model.pOrder
	case 'none'
		P = [];
		nP = 0;
	case 'constant'
		P = ones(model.nX, 1);
		nP = 1;
	case 'linear'
		P = [ones(model.nX, 1), model.Xt];
		nP = 1 + model.nVar;
	case 'pureQuadratic'
		P = [ones(model.nX, 1), model.Xt, (model.Xt).^2];
		nP = 1 + model.nVar + model.nVar;
	otherwise
		P = [];
		nP = 0;
end

A = [Phi,	P; ...
	 P',	zeros(nP, nP)];
b = [model.Yt; ...
	 zeros(nP, 1)];
 
model.alpha = A\b;

end

function [y] = predict_rbf_model(x, model)
% Evaluates a point from a RBF model (no data checking)

X = x ./ model.scale;
phi = model.RBF(sqrt(sum((model.Xt - X).^2, 2)));

switch model.pOrder
	case 'none'
		p = [];
	case 'constant'
		p = 1;
	case 'linear'
		p = [1; X'];
	case 'pureQuadratic'
		p = [1; X'; (X').^2];
	otherwise
		p = [];
end

y = dot([phi; p], model.alpha);

end

% Define Radial Basis Functions
function [y] = RBF_linear(r)
	y = r;
end
function [y] = RBF_gaussian(r)
	y = exp(-1*r.^2);
end
function [y] = RBF_thinPlateSpline(r)
	y = r.^2.*log(r);
	y(r==0) = 0;
end
function [y] = RBF_cubicSpline(r)
	y = r.^3;
end
