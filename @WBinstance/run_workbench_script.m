function [obj, runTimeSec] = run_workbench_script(obj, echoBool)
%run_workbench_script Runs the current Workbench script, returns run time
%	Part of the WBinstance class

command = ['"' obj.workbenchExecPath '"'];
arguments = [' -B -R "' obj.scriptFilePath '"'];

% Run the command with timing
tic;
if echoBool
	[status, message] = system([command arguments], '-echo');
else
	[status, message] = system([command arguments]);
end
runTimeSec = toc;

% Archive the (now-used) script file
obj = obj.clear_workbench_script(true);

% Show error message if the command could not be completed
if status ~= 0
	error('System command returned with a non-zero status: %d\n\t"%s"', status, message)
end

end

