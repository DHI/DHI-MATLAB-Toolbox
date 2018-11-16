function [netElmts] = mzNetToElmtArray(elmts)
%MZNETTOELMTARRAY Convert Matlab elmt matrix to .NET elmt array
%
%   Converts a Matlab element matrix to .NET element array table.
%  
%   Usage:
%     [netElmts] = mzNetToElmtArray(elmts)
%
%   Inputs:
%     elmts   : Element matrix
%
%   Outputs:
%     netElmt : Element table in the form of a .NET, int[][].

% Copyright, DHI, 2010-08-20. Author: JGR

% Create element table in .NET format
H = NETaddDfsUtil();
if (~isempty(H))
    % Use the MatlabDfsUtil.dll for doing the conversion.
    netElmts = MatlabDfsUtil.DfsUtil.ToElementTable(NET.convertArray(int32(elmts)));
else
    % The MatlabDfsUtil.dll could not be loaded. Try manual conversions
    netElmts = NET.createArray('System.Int32[]',size(elmts,1));
    for i=1:size(elmts,1)
        elmt = elmts(i,:);
        elmt = elmt(elmt~=0);  % remove zeros
        netElmts(i) = NET.convertArray(int32(elmt));
    end
end