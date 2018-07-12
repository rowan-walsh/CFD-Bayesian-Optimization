function [obj] = change_initialize(obj, initializeDesignPointIndex)
%change_initialize Changes the initializeFrom design point. If no input is
%passed, defaults to 1.
%	Part of the WBdesignPointList class

if nargin < 2
	% Set to default value
	obj.initializeFrom = 1;
else
	% Check input validity
	if initializeDesignPointIndex > obj.amount || initializeDesignPointIndex < 1
		error('Design point index for initializeFrom does not exist.')
	end
	
	if obj.new(initializeDesignPointIndex)
		warning('Design point set to initializeFrom is new: will not be useful for initialization.')
	elseif any(obj.needsUpdate(initializeDesignPointIndex,:))
		warning('Design point set to initializeFrom needs updating: will not be useful for initialization.')
	end
	
	if ~obj.valid(initializeDesignPointIndex)
		error('Design point index for initializeFrom does not have valid geometry.')
	end
	
	% Set index
	obj.initializeFrom = initializeDesignPointIndex;
end

end

