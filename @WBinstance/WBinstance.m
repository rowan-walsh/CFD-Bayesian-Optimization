classdef WBinstance < handle
	%WBinstance	class
	%	This class represents a particular Ansys Workbench project, for
	%	which scripts are made to pass parameters for design points and
	%	retrieve simulation results.
	
	properties
		projectPath
		
		scriptFilePath
				
		designPoints
		
		seekPolynomial
		seekInputParamInd
		seekOutputParamInd
		iterationsParamInd
	end
	
	properties (Access = protected)
		workbenchInstallFolder = 'C:\Program Files\ANSYS Inc';
		workbenchVersion = '17.1';
		workbenchPlatform = 'Win64';
		workbenchExecPath;
	end
	
	methods
		% Constructor method
		function obj = WBinstance(projectFilePath)
			if nargin < 1
				error('Too few arguements passed.');
			else
				% Check project file exists
				if exist(projectFilePath, 'file') == 0
					error('Project file specified does not exist.')
				end
				
				% Set up project path
				obj.projectPath = projectFilePath;
			end
			
			% Create default WB-opening command path
			obj.workbenchExecPath = [ ...
				obj.workbenchInstallFolder ...
				'\v' strrep(obj.workbenchVersion, '.', '') ...
				'\Framework\bin' ...
				'\' obj.workbenchPlatform ...
				'\RunWB2' ];
			
			% Set up generated script handle
			obj.scriptFilePath = [fileparts(projectFilePath) '\workbenchScript.wbjn'];
			%obj.scriptFileID = fopen(obj.scriptFilePath, 'w');
						
			% Construct design-point list object from past project data
			[obj, pastDataExportPath] = obj.export_past_project_data();
			obj.designPoints = WBdesignPointList(pastDataExportPath);
			
			% Set default (non-working) seek values
			obj.seekPolynomial = [0 0 0];
			obj.seekInputParamInd = 0;
			obj.seekOutputParamInd = 0;
			obj.iterationsParamInd = 0;
		end

		[obj] = set_WB_installation(obj, installationFolder, installationVersion, platform)
		[obj] = set_seek_polynomial(obj, polyVector)
		[obj] = set_seek_input_parameter(obj, paramIndex)
		[obj] = set_seek_output_parameter(obj, paramIndex)
		[obj] = set_iterations_parameter(obj, paramIndex)
		[obj, workbenchRunTimeSec, successBool] = run_set(obj, designPointIndices, simType, debugModeBool)
		[index] = check_param_index(obj, identifier)
	end

	methods(Access = private) % Private methods
		[obj, pastDataExportPath] = export_past_project_data(obj)
		[obj, runTimeSec] = run_workbench_script(obj, echoBool)
		[obj] = clear_workbench_script(obj, saveScriptBool)
		[obj, messageInfo, message] = import_messages(obj)
	end
end

