function [validOptions, validBool] = validate_options(options)
%VALIDATE_OPTIONS Checks/fills-in MOSAO options struct
%	VALIDOPTIONS	A copy of OPTIONS with all empty fields filled in 
%					with default values. If there was no function input, 
%					returns the default options struct.
%	VALIDBOOL		Indicates if the input OPTIONS contains no invalid 
%					fields as a MOSAO options struct.
%	
%	Part of the MOSAO class.

validBool = true;

% Set options as empty if not input so it picks up default values
if nargin < 1 || isempty(options)
	validBool = false;
	options = struct();
end

% Check options is a struct
if not(isstruct(options))
	warning('MOSAO:BadOptionsType', 'Options was not the right object type, setting to defaults.');
	validBool = false;
	options = struct();
end

% Set default options values
defaultOptions.initCalls =			50;
defaultOptions.initType =			'uniform';
defaultOptions.maxCalls =			500;
defaultOptions.maxCandidates =		15;
defaultOptions.minSortDistance =	1e-4;
defaultOptions.populationSize =		50;
defaultOptions.crossoverRatio =		0.6;
defaultOptions.mutationRate =		0.01;
defaultOptions.type =				'ga';
defaultOptions.GAcriteria =			'PoI';
defaultOptions.sortCriteria =		'PoI';
defaultOptions.GAgenerations =		1;
defaultOptions.GSbasis =			'constant';
defaultOptions.GSkernel =			'ardsquaredexponential';
defaultOptions.noiseSigma =			0;
defaultOptions.constantNoiseSigma =	false;
defaultOptions.LSmodelPoints =		50;
defaultOptions.LSmaxRounds =		3;
defaultOptions.LSrbf =				'linear';
defaultOptions.LSbasis =			'constant';
defaultOptions.LSuseValidOnly =		false;
defaultOptions.reuseKernel =		true;
defaultOptions.GSinvalidTransform =	'none';
defaultOptions.GSuseClassifier =	false;
defaultOptions.showMessages =		false;

defaultOptions.BayesAcqFunc =		'PoI';
defaultOptions.BayesNstarts =		100;
defaultOptions.BayesNcandidates =	1;
defaultOptions.BayesParallelMS =	false;

defaultOptions.BayesMOAcqFunc =		'PoPI';
defaultOptions.hypervolumeRef =		[];

% Set fields that don't exist or are empty to defaults
Names = fieldnames(defaultOptions);
for i = 1:size(Names,1)
	if ~isfield(options, Names{i}) || isempty(options.(Names{i}))
		options.(Names{i}) = defaultOptions.(Names{i});
	end
end

% Check for validity
if ~ischar(options.initType) || ~any(strcmp(options.initType, {'uniform', 'latinhypercube'}))
	warning('MOSAO:MiscOptionsInvalid', 'initType not valid: set to default');
	options.initType = defaultOptions.initType;
	validBool = false;
end
if options.maxCalls < options.initCalls
	warning('MOSAO:MiscOptionsInvalid', 'maxCalls was lower than initCalls: set to be equal.');
	options.maxCalls = options.initCalls;
	validBool = false;
end
if options.maxCandidates > options.populationSize
	warning('MOSAO:MiscOptionsInvalid', 'maxCandidates was greater than populationSize: set to be equal.');
	options.maxCandidates = options.populationSize;
	validBool = false;
end
if options.crossoverRatio > 0.9 || options.crossoverRatio < 0
	warning('MOSAO:MiscOptionsInvalid', 'crossoverRatio oustide of [0, 0.9]: set to default');
	options.crossoverRatio = defaultOptions.crossoverRatio;
	validBool = false;
end
if options.mutationRate > 1 || options.mutationRate < 0
	warning('MOSAO:MiscOptionsInvalid', 'mutationRate oustide of [0, 1]: set to default');
	options.mutationRate = defaultOptions.mutationRate;
	validBool = false;
end
if ~ischar(options.type) || ~any(strcmp(options.type, {'ga', 'saga-gs', 'saga-ls', 'saga-gls', 'b', 'bls'}))
	warning('MOSAO:MiscOptionsInvalid', 'Type not valid: set to default');
	options.type = defaultOptions.type;
	validBool = false;
end
if ~ischar(options.GAcriteria) || ~any(strcmp(options.GAcriteria, {'fitness', 'PoI', 'EI'}))
	warning('MOSAO:MiscOptionsInvalid', 'GAcriteria not valid: set to default');
	options.GAcriteria = defaultOptions.GAcriteria;
	validBool = false;
end
if ~ischar(options.sortCriteria) || ~any(strcmp(options.sortCriteria, {'fitness', 'PoI', 'EI'}))
	warning('MOSAO:MiscOptionsInvalid', 'sortCriteria not valid: set to default');
	options.sortCriteria = defaultOptions.sortCriteria;
	validBool = false;
end
if ~ischar(options.GSbasis) || ~any(strcmp(options.GSbasis, {'none', 'constant', 'linear', 'pureQuadratic'}))
	warning('MOSAO:MiscOptionsInvalid', 'GSbasis not valid: set to default');
	options.GSbasis = defaultOptions.GSbasis;
	validBool = false;
end
if ~ischar(options.GSkernel) || ~any(strcmp(options.GSkernel, ...
		{'exponential', 'squaredexponential', 'matern32', 'matern52', 'rationalquadratic', ...
		'ardexponential', 'ardsquaredexponential', 'ardmatern32', 'ardmatern52', 'ardrationalquadratic'}))
	warning('MOSAO:MiscOptionsInvalid', 'GSkernel not valid: set to default');
	options.GSkernel = defaultOptions.GSkernel;
	validBool = false;
end
if ~ischar(options.LSrbf) || ~any(strcmp(options.LSrbf, {'linear', 'gaussian', 'thinplatespline', 'cubicspline'}))
	warning('MOSAO:MiscOptionsInvalid', 'LSrbf not valid: set to default');
	options.LSrbf = defaultOptions.LSrbf;
	validBool = false;
end
if ~ischar(options.LSbasis) || ~any(strcmp(options.LSbasis, {'none', 'constant', 'linear', 'pureQuadratic'}))
	warning('MOSAO:MiscOptionsInvalid', 'LSbasis not valid: set to default');
	options.LSbasis = defaultOptions.LSbasis;
	validBool = false;
end
if ~ischar(options.GSinvalidTransform) || ~any(strcmp(options.GSinvalidTransform, {'none', 'mean', 'worst', 'remove'}))
	warning('MOSAO:MiscOptionsInvalid', 'GSinvalidTransform not valid: set to default');
	options.GSinvalidTransform = defaultOptions.GSinvalidTransform;
	validBool = false;
end

if ~ischar(options.BayesAcqFunc) || ~any(strcmp(options.BayesAcqFunc, {'fitness', 'PoI', 'EI'}))
	warning('MOSAO:MiscOptionsInvalid', 'BayesAcqFunc not valid: set to default');
	options.BayesAcqFunc = defaultOptions.BayesAcqFunc;
	validBool = false;
end

if ~ischar(options.BayesMOAcqFunc) || ~any(strcmp(options.BayesMOAcqFunc, {'HVIncreaseMean', 'HVIncreaseLCB', 'PoPI', 'EHVI'}))
	warning('MOSAO:MiscOptionsInvalid', 'BayesMOAcqFunc not valid: set to default');
	options.BayesMOAcqFunc = defaultOptions.BayesMOAcqFunc;
	validBool = false;
end

% Assign output
validOptions = options;

end
