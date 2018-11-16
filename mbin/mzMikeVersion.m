function ver = mzMikeVersion(dfsAssemblyName)
%mzMikeVersion Determines the version of the installed MIKE software
%
%   Determines the version of the currently installed MIKE software
%  
%   Usage:
%     ver = mzMikeVersion()
%
%   Outputs:
%     ver : Version, being 2011, 2012 or 2014
%
%   Note that the version number changes with each release of MIKE by DHI.
%

% Copyright, DHI, 2014-01-20. Author: JGR

% Only load once, store it for reuse, as persisten variable
persistent mzVer;

if (isempty(mzVer))
    
    % Not yet determined
    
    if nargin == 0
        dfsAssemblyName = 'DHI.Generic.MikeZero.DFS';
    end
    
    dfsAss = NET.addAssembly(dfsAssemblyName);
    dfsAssVer = dfsAss.AssemblyHandle.GetName().Version.Major;
    
    switch dfsAssVer
        case 17 % Release 2019
            mzVer = 2019;
        case 16 % Release 2017
            mzVer = 2017;
        case 15 % Release 2016
            mzVer = 2016;
        case 14 % Release 2014
            mzVer = 2014;
        case 13 % Release 2012
            mzVer = 2012;
        case 10 % Release 2011
            mzVer = 2011;
        otherwise
            msgs = ['Could not determine version of installed MIKE'];
            disp(msgs);
            mzVer = [];
    end
end

ver = mzVer;
