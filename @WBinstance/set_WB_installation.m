function [obj] = set_WB_installation(obj, installationFolder, installationVersion, platform )
%SET_WB_INSTALLATION Updates the WBinstance's WB installation details

if nargin == 4
	obj.workbenchInstallFolder = installationFolder;
	obj.workbenchVersion = installationVersion;
	obj.workbenchPlatform = platform;
else
	error('Wrong amount of input arguments.')
end

% Create WB-opening command path
obj.workbenchExecPath = [ ...
	installationFolder ...
	'\v' strrep(installationVersion, '.', '') ...
	'\Framework\bin' ...
	'\' platform ...
	'\RunWB2' ];

end
