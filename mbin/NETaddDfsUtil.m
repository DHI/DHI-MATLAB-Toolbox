function H = NETaddDfsUtil(dfsAssemblyName)
%NETaddDfsUtil Load MatlabDfsUtil helper dll
%
%   Loads the version of the MatlabDfsUtil library matching the installed
%   version of MIKE Zero.
%
%   The MatlabDfsUtil library contains a number of helper functions for
%   functionality that is slow if performed directly in Matlab
%  
%   Usage:
%     H = NetAddDfsUtil()
%     H = NetAddDfsUtil(dfsAssemblyName)  (*1)
%
%   Inputs:
%     dfsAssemblyName : Name of dfs assembly, either the short name or the
%         fully qualified/long form of the assembly name (including 
%         Version, Culture and PublicKeyToken).
%
%   Outputs:
%      H : Assembly handle, or an empty array if not found.
%
%   The short name is just DHI.Generic.MikeZero.DFS. The long form of the
%   name is on the form:
%
%     DHI.Generic.MikeZero.DFS, Version=14.0.0.0, Culture=neutral, 
%       PublicKeyToken=c513450b5d0bf0bf
%   
%   Note that the version number changes with each release of MIKE by DHI.
%
%   Use (*1) only if you have problems loading the correct version of the
%   assembly.

% Copyright, DHI, 2014-01-20. Author: JGR

% Only load once, store it for reuse, as persisten variable
persistent DfsUtilAss;

if (isempty(DfsUtilAss))
    
    % Not yet loaded, try to load it
    
    if nargin == 0
        dfsAssemblyName = 'DHI.Generic.MikeZero.DFS';
    end
    
    dfsAss = NET.addAssembly(dfsAssemblyName);
    dfsAssVer = dfsAss.AssemblyHandle.GetName().Version.Major;
    
    switch dfsAssVer
        case 18 % Release 2020
            DfsUtilAss = NETaddAssembly('MatlabDfsUtil.2020.dll');
        case 17 % Release 2019
            DfsUtilAss = NETaddAssembly('MatlabDfsUtil.2019.dll');
        case 16 % Release 2017
            DfsUtilAss = NETaddAssembly('MatlabDfsUtil.2017.dll');
        case 15 % Release 2016
            DfsUtilAss = NETaddAssembly('MatlabDfsUtil.2016.dll');
        case 14 % Release 2014
            DfsUtilAss = NETaddAssembly('MatlabDfsUtil.2014.dll');
        case 13 % Release 2012
            DfsUtilAss = NETaddAssembly('MatlabDfsUtil.2012.dll');
        case 10 % Release 2011
            DfsUtilAss = NETaddAssembly('MatlabDfsUtil.2011.dll');
        otherwise
            msgs = ['Loading of MatlabDfsUtil failed, not available for Version ', num2str(dfsAssVer)];
            disp(msgs);
            DfsUtilAss = [];
    end
end

H = DfsUtilAss;
