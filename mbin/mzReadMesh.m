function [Elmts,Nodes,proj,zUnitKey] = mzReadMesh(filename)
%READMESH Reads MikeZero .mesh file.
%
%   Reades nodes and element connectivity from a .mesh file.
%
%   Usage:
%       [Elmts,Nodes,proj,zUnitKey] = mzReadMesh(filename)
%
%   Outputs:
%       Elmts    : Element-Node table, for each element list the node number,
%                  e.g., as returned by the delaunay function.
%       Nodes    : Node coordinates having 4 columns, [x, y, z, code]
%       proj     : Projection string of mesh.
%       zUnitKey : EUM Unit key for Z values in mesh. Common values:
%                    1000 = meter
%                    1014 = feet (US)
%                  Check EUM system for details (EUM.xml)
%
%   See also MZWRITEMESH

% Copyright, DHI, 2007-11-09. Author: JGR
% Modified, 2013-02-22 JGR: support for z unit key in mesh files

if (nargin == 0)
  [uifilename,uifilepath] = uigetfile('*.mesh','Select a .mesh file');
  filename = [uifilepath,uifilename];
end

fid    = fopen(filename,'rt');
if fid == -1
  error('mzTool:mzReadMesh:fileNotFound',['Could not find file: ' filename]);
end

% Scan for number of nodes
% nnodes = fscanf(fid,'%d',1);
nnodes_temp = fscanf(fid,'%d',3); 
if length(nnodes_temp)==3
    nnodes = nnodes_temp(3); %if MIKE 2013 Mesh
    zUnitKey = nnodes_temp(2);
else
    nnodes = nnodes_temp(1); %if previous version 
    zUnitKey = 1000;
end


% Get remainder of line, projection name
tline  = fgetl(fid);
% Scan for projection string
proj   = tline(1:end);
while (proj(1) == ' ')           % Remove preceding spaces
  proj = proj(2:end);
end
% Read all node data
Nodes    = fscanf(fid,'%f %f %f %f %f\n',[5,nnodes]);
Nodes    = Nodes';

% Read element header line
tline    = fgetl(fid);
tmp      = sscanf(tline,'%d',3);
nelmts   = tmp(1);                 % number of elements
npelmt   = tmp(2);                 % Nodes per element
elmttype = tmp(3);                 % Element type (21 for triangles, 25 for mixed)

% Read all element data
if (npelmt == 3)
  Elmts  = fscanf(fid,'%f %f %f %f',[4,nelmts]);
elseif (npelmt == 4)
  Elmts  = fscanf(fid,'%f %f %f %f %f',[5,nelmts]);
else
  error('mzTool:mzReadMesh:unsupportedMeshFormat',...
        'This mesh format is not supported, or there is an error in the mesh file.')
end
Elmts  = Elmts';

% Remove index number (always 1-incrementing, not needed)
Nodes  = Nodes(:,2:end);
Elmts  = Elmts(:,2:end);

fclose(fid);
