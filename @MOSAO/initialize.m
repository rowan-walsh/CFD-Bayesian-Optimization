function [obj] = initialize(obj, initialX)
%INITIALIZE Adds initial set of X to Database
%   INITIALX:	Row-wise set of X vectors to add to the SAGA's Database, 
%				overriding and overwriting options.initCalls.
%
%	If no input is given, creates a set with n=opt.initCalls vectors.
%
%	Part of the MOSAO class.

% Initialize empty initialX if none is passed in
if nargin < 2
	initialX = [];
end

% Add to initialX if it is shorter than opt.initCalls
nX = size(initialX, 1);
missingCalls = obj.opt.initCalls - nX;
if missingCalls > 0
	switch obj.opt.initType
		case 'uniform'
			base = rand(missingCalls, obj.db.lenX);
		case 'latinhypercube'
			base = zeros(missingCalls, obj.db.lenX);
			for i = 1 : obj.db.lenX
				base(:, i) = (rand(1, missingCalls) + (randperm(missingCalls) - 1))' / missingCalls;
			end
		otherwise
			error('MOSAO:UnrecognizedInitType', 'Unrecognized opt.initType');
	end
	initialX = [ ...
		initialX; ...
		obj.db.LB + (obj.db.UB - obj.db.LB) .* base ];
end

% Skip steps if initialX is empty
if ~isempty(initialX)
	% Check initialX for size and bounds
	if ~all(obj.db.check_bounds(initialX))
		error('MOSAO:BadInitialX', 'initialX violates the bounds or is not the right length.');
	end

	% Run function on initialX
	[obj.db, iCalled] = obj.db.call_function(initialX);

	% Check function output
	if length(iCalled) ~= size(initialX, 1)
		error('MOSAO:BadDBOutputLength', 'Database function call did not return the expected number of results.');
	end
end

end
