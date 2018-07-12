function [obj] = clear_workbench_script(obj, saveScriptBool)
%clear_workbench_script Clears the script file, optionally saves it
%	Part of the WBinstance class

if nargin < 2
	saveScriptBool = true;
end

% % Close the script file
% try
% 	fclose(obj.scriptFileID);
% catch
% 	% Nothing...
% end

% Optional: save old script file
if saveScriptBool
	% Get script archive file path
	scriptArchiveFilePath = [fileparts(obj.scriptFilePath) '\workbenchScriptArchive.wbjn'];
	scriptArchiveFileID = fopen(scriptArchiveFilePath, 'a');
	
	% Save a copy of the current script to the archive
	fullScriptFileContents = fileread(obj.scriptFilePath);
	fprintf(scriptArchiveFileID, '\n############# %s #############\n', datestr(now));
	fprintf(scriptArchiveFileID, '\n%s', fullScriptFileContents);
	
	% Close script archive file path
	fclose(scriptArchiveFileID);
end

% Re-open and close the script file to overwrite it
fileID = fopen(obj.scriptFilePath, 'w');
fclose(fileID);

end
