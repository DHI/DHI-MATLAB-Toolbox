function [netCoords] = mzNetToCoordArray(x,y,z)
%MZNETTOCOORDARRAY  Convert Matlab coordinate vectors to .NET Coords[]
%
%   Convert Matlab coordinate vectors to .NET Coords[]
%  
%   Usage:
%     [netCoords] = mzNetToCoordArray(elmts)
%
%   Inputs:
%     elmts   : Element matrix
%
%   Outputs:
%     netElmt : Element table in the form of a .NET, int[][].

% Copyright, DHI, 2010-08-20. Author: JGR

netCoords = NET.createArray('DHI.Generic.MikeZero.DFS.Coords',numel(x));
for i=1:numel(x)
  netCoords(i) = DHI.Generic.MikeZero.DFS.Coords(x(i),y(i),z(i));
end