function asm = NETaddAssembly(asmName)
% NETaddAssembly makes a .NET assembly visible to MATLAB.
%   A = NETaddAssembly(asmName) 
%   makes an assembly visible to MATLAB and returns and instance of
%   NET.Assembly class.
% 
%   asmName is one of the following:
%   - string that represents name of the assembly, without .dll exension.
%   - string that represents file name of assembly, either the file name
%     alone or the full path to the assembly. This string must end with
%     .dll.
%   - an instance of System.Reflection.AssemblyName class.
%
%   Compared to the NET.addAssembly method, this allows for private names
%   without specifying the full path, as long as the assembly dll file is
%   contained within the Matlab search path.

% Check if it is a string name  
if (~ischar(asmName))
    % Not a string, just call on.
    asm = NET.addAssembly(asmName);
end

% Check if the asmName string ends with .dll
if (numel(asmName) >= 4 && strcmp(lower(asmName(end-3:end)),'.dll'))
    % Private dll, try to find full path.
    fullPath = which(asmName);
    % Full path not found, use asmName instead.
    if (numel(fullPath) == 0)
        fullPath = asmName;
    end
    asm = NET.addAssembly(fullPath);
else
    % GAC dll, no special action.
    asm = NET.addAssembly(asmName);
end