function [meanOutput] = acquisition_mean(x, models, acqFunc)
%ACQUISITION_MEAN Averages the acq. results from several models at x
%
%	X		List of x locations (each row is a location) to be evaluated
%	MODELS	List of models to be used (2D cell array, )
%	ACQFUNC	Function handle to the acquisition function, takes two
%			arguments: x and model.

nModels = size(models, 1);
nX = size(x, 1);

outputList = NaN(nX, nModels);

% Evaluate acqusition function for each model
for ind = 1:nModels
	outputList(:,ind) = acqFunc(x, models(ind,:));
end

% Average results
meanOutput = mean(outputList, 2);

% nY = size(models, 2);
% meanOutput = NaN(nX, nY);
% 
% % For each objective
% for j = 1:nY
% 	% Evaluate acquisition function for each model
% 	outputList = NaN(nX, nModels);
% 	for ind = 1:nModels
% 		outputList(:,ind) = acqFunc(x, models{ind,j});
% 	end
% 	meanOutput(:,j) = mean(outputList, 2);
% end

end

