function [Elmts,Nodes] = triangleReadMesh(filename)
%TRIANGLEREADMESH Reads Triangle mesh files.
%
%   Reades nodes and element connectivity from a set of mesh files created
%   by Triangle. Will expect two files named:
%       filename.node
%       filename.ele
%
%   Usage:
%       [Elmts,Nodes] = triangleReadMesh(filename)
%
%   Input:
%       filename : Name of file, without extension.
%
%   Output:
%       Elmts    : Element-Node table, for each element list the node
%                  number, e.g., as returned by the delaunay function.
%       Nodes    : Node coordinates having 4 columns, [x, y, z, code]
%
%   Acknowledgment: Triangle - a two dimensional mesh generator by Jonathan
%   Richard Shewchuk

fid    = fopen([filename '.node'],'rt');
tline  = fgetl(fid);
nnodes = sscanf(tline,'%d ',1)
Nodes  = fscanf(fid,'%f %f %f %f %f\n',[5,nnodes]);
Nodes  = Nodes';
fclose(fid)

fid    = fopen([filename '.ele'],'rt');
tline  = fgetl(fid);
nelmts = sscanf(tline,'%d',1)
Elmts  = fscanf(fid,'%f %f %f %f',[4,nelmts]);
Elmts  = Elmts';
fclose(fid)

Nodes  = Nodes(:,2:end);
Elmts  = Elmts(:,2:end);