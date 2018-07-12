classdef WBdesignPointList
	%WBdesignPointList
	%	This class represents a set of Ansys Workbench design-points
	
	%TBC Once methods are finished, decide which of these should be
	% private, hidden, etc.
	properties
		paramAmount
		paramNames
		paramDescriptions
		paramUnits
		paramMutable
		
		amount
		names
		new
		needsUpdate
		valid
		data
		initializeFrom
	end
	
	methods
		% Constructor Method
		function obj = WBdesignPointList(projectDataPath)
			if nargin == 0 % Set default (empty) construction
				warning('No project data path provided for WBdesignPointList constructor.')
				
				obj.paramAmount = 0;
				obj.paramNames = {};
				obj.paramDescriptions = {};
				obj.paramUnits = {};
				obj.paramMutable = [];
			
				obj.amount = 0;
				obj.names = {};
				obj.new = [];
				obj.needsUpdate = [];
				obj.valid = [];
				obj.data = [];
				obj.initializeFrom = 0;
				
				return;
			end
				
			% Open the project data file
			fileID = fopen(projectDataPath, 'r');

			if fileID == -1
				error('Data export file could not be opened:\n\t%s', projectDataPath);
			else
				% Skip header lines
				for i=1:3; fgetl(fileID); end
				
				% Skip blank line
				fgetl(fileID);

				% Import the designPoint attributes
				tempLineData = textscan(fgetl(fileID), '%s', 'Delimiter', ',');
				obj.names = tempLineData{:}(2:end);
				obj.amount = size(obj.names, 1);

				tempLineData = textscan(fgetl(fileID), '%s', 'Delimiter', ',');
				tempDesignPointsNeedingUpdate = ~(cell2mat(tempLineData{:}(2:end)) == '1'); % Converts to boolean
				
				tempLineData = textscan(fgetl(fileID), '%s', 'Delimiter', ',');
				obj.valid = cell2mat(tempLineData{:}(2:end)) == '1'; % Converts to boolean

				% Skip blank line
				fgetl(fileID);
	
				% Import the parameter attributes
				tempLineData = textscan(fgetl(fileID), '%s', 'Delimiter', ',');
				obj.paramNames = tempLineData{:}(2:end);
				
				tempLineData = textscan(fgetl(fileID), '%s', 'Delimiter', ',');
				obj.paramDescriptions = tempLineData{:}(2:end);
				
				tempLineData = textscan(fgetl(fileID), '%s', 'Delimiter', ',');
				obj.paramUnits = tempLineData{:}(2:end);
				
				tempLineData = textscan(fgetl(fileID), '%s', 'Delimiter', ','); % Usage
				tempLineData2 = textscan(fgetl(fileID), '%s', 'Delimiter', ','); % Expression
				obj.paramMutable = and(strcmp(tempLineData{:}(2:end), 'Input'), ~strcmp(tempLineData2{:}(2:end), 'Derived'));
				
				% Check imported data dimensions are equal
				if ~isequal(size(obj.paramNames), size(obj.paramDescriptions), ...
						size(obj.paramUnits), size(obj.paramMutable))
					error('Parameter data from export file was not read to have equal sizes.');
				else
					obj.paramAmount = size(obj.paramNames, 1);
				end
				
				% Read data and design point names
				tempLineData = textscan(fileID, '%[^,],%s', 'Delimiter', '\n');

				% Save design point names
				obj.names = tempLineData{1};
				obj.amount = size(obj.names, 1);

				% Save data
				for i = 1:obj.amount
					obj.data(i,:) = cell2mat(textscan(tempLineData{2}{i}, '%f', 'Delimiter', ','))';
				end
				
				% Set update flags
				obj.new = false(size(obj.names));
				obj.needsUpdate = repmat(and(tempDesignPointsNeedingUpdate, obj.valid), 1, obj.paramAmount);
				
				% Set initialize to default (1)
				obj.initializeFrom = 1;
				
				fclose(fileID);
			end
		end
		
		[obj, newDesignPointIndex] = add_new(obj, newDesignPointData)
		[obj, newDesignPointIndex] = add_copy(obj, copyDesignPointIndex)
		[obj] = change_value(obj, designPointIndex, paramIndex, value, retainValidity)
		[obj] = change_initialize(obj, initializeDesignPointIndex)
	end
end

