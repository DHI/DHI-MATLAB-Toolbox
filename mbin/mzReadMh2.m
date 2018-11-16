function [Elmts,Nodes] = mzReadMh2(filename)
%MZREADMH2 Reads .mh2 file.
%
%   Reades nodes and element connectivity from a .mh2 file.
%
%   The .mh2 file is the output mesh from Geompack++
%
%   Usage:
%       [Elmts,Nodes] = mzReadMh2(filename)
%
%   Outputs:
%       Elmts : Element-Node table, for each element list the node number,
%               e.g., as returned by the delaunay function.
%       Nodes : Node coordinates having 3 columns, [x, y, z]

% Copyright, DHI, 2010-08-00.

fid    = fopen(filename,'rt');
if fid == -1
  error('mzTool:mzReadMh2:fileNotFound',['Could not find file: ' filename]);
end

% Get first line of file, node and projection header line
tline  = fgetl(fid);
% Scan for number of nodes
nnodes = sscanf(tline,'%d',1);
% Read all node data
Nodes    = fscanf(fid,'%f %f %f\n',[3,nnodes]);
Nodes    = Nodes';

% Read node extra info
tline    = fgetl(fid);
while (length(tline) < 1)
  tline    = fgetl(fid);
end
tmp      = sscanf(tline,'%d',1);
for i=1:tmp
  fgetl(fid);
end

tline    = fgetl(fid);
while (length(tline) < 1)
  tline    = fgetl(fid);
end
tmp = sscanf(tline,'%d',2);
npelmt   = tmp(1);                 % Nodes per element
nelmts   = tmp(2);                 % number of elements

% Read all element data
if (npelmt == 3)
  Elmts  = fscanf(fid,'%f %f %f %f',[3,nelmts]);
elseif (abs(npelmt) == 4)
  Elmts  = fscanf(fid,'%f %f %f %f',[4,nelmts]);
else
  error('mzTool:mzReadMh2:unsupportedMeshFormat',...
        'This mesh format is not supported, or there is an error in the mesh file.')
end
Elmts  = Elmts';

fclose(fid);
