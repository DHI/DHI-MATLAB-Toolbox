function [elmts] = mzNetFromElmtArray(netElmts)
%MZNETFROMELMTARRAY Convert .NET elmt array to Matlab elmt matrix
%
%   Converts a .NET element array table to Matlab element matrix. The
%   element matrix will have zeros for elements with fewer nodes in element
%   than the number of columns in the matrix (mixed
%   triangular-quadrilateral meshes).
%  
%   Usage:
%     [elmts] = mzNetFromElmtArray(netElmts)
%
%   Inputs:
%     netElmt : Element table in the form of a .NET, int[][].
%
%   Outputs:
%     elmts   : Element matrix

% Copyright, DHI, 2010-08-20. Author: JGR

% Create element table/matrix in Matlab format, putting zeros for elements
% with fewer nodes than number of columns in matrix.

H = NETaddDfsUtil();
if (~isempty(H))
    % Use the MatlabDfsUtil.dll for doing the conversion.
    elmts = double(MatlabDfsUtil.DfsUtil.ToElementMatrix(netElmts));
else
    % The MatlabDfsUtil.dll could not be loaded. Try manual conversions
    try
        % Create element table in Matlab format. This is not supported by
        % older versions of MATLAB and will fail.
        celmts = cell(netElmts);
        % Create element matrix from cell array
        elmts = zeros(numel(celmts),1);
        for i = 1:numel(celmts),
            elmtsi = celmts{i};
            elmts(i,1:numel(elmtsi)) = elmtsi; 
        end
    catch exception
        disp('WARNING: Converting ElementTable using MATLAB cell functionality failed.');
        disp('Older version of MATLAB does not support this cell functionality.');
        disp('Conversion of element table can be slow!');
        elmts = zeros(netElmts.Length,1);
        for i=0:netElmts.Length-1
            elmt = double(netElmts.Get(i));
            elmts(i+1,1:numel(elmt)) = elmt;
        end
    end
end

