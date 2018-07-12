function  [obj, messageInfo, message] = import_messages(obj)
%import_messages Imports the messages from the most recent WB batch-run
%   Part of the WBinstance class

messageExportPath = [fileparts(obj.projectPath) '\messages.txt'];
fileID = fopen(messageExportPath, 'r');

i = 0;
messageInfo = cell(0);
message = cell(0);
newCell = false;
typeLinePrefix = '----- ';

tempLine = fgetl(fileID);
while ischar(tempLine)
	if strncmp(tempLine, typeLinePrefix, size(typeLinePrefix, 2))
		i = i + 1;
		messageInfo{i} = tempLine(size(typeLinePrefix, 2)+1:end);
		newCell = true;
	elseif newCell
		message{i} = tempLine;
		newCell = false;
	else
		message{i} = sprintf('%s\n%s', message{i}, tempLine);
	end
		
	tempLine = fgetl(fileID);
end

fclose(fileID);
end

