function [Nodes,Loops] = mzReadRg2(filename)
%MZREADRG2 Reads .rg2 file.
%
%   Reades nodes and loopes an .rg2 file.
%
%   The .rg2 file a 2D region file used as input to Geompack++
%   It contains nodes/vertices, loops and curves
%
%   Usage:
%       [Nodes,Loops] = mzReadRg2(filename)
%
%   Outputs:
%       Nodes : Node coordinates having 3 columns, [x, y, z]
%       Loops : ???

% Copyright, DHI, 2010-08-00.

fid    = fopen(filename,'rt');
if fid == -1
  error('mzTool:mzReadRg2:fileNotFound',['Could not find file: ' filename]);
end

% Get first line of file, number of nodes
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

% Read loop info
tline    = fgetl(fid);
while (length(tline) < 1)
  tline    = fgetl(fid);
end
nloops = sscanf(tline,'%d',1);

for i=1:nloops
  tline    = fgetl(fid);
  while (length(tline) < 1)
    tline    = fgetl(fid);
  end
  tmp               = sscanf(tline,'%d',3);
  Loops{i}.nv       = tmp(1);
  Loops{i}.regcode  = tmp(2);
  Loops{i}.inreg    = tmp(3);
  tline             = fgetl(fid);
  Loops{i}.v        = sscanf(tline,'%d',Loops{i}.nv);
  tline             = fgetl(fid);
  Loops{i}.edgeinfo = sscanf(tline,'%d',Loops{i}.nv);
end
