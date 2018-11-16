function [Elmts,Nodes,err] = mzMeshQuadFromTriFace(Elmts,Nodes,nn1,nn2)
% MZMESHQUADFROMTRIFACE Make quad from 2 triangles over face
%
%   Makes a new quad from two triangels sharing the face defined by two
%   nodes
%
%   Usage
%     [Elmts,Nodes] = mzMeshCollapseFace(Elmts,Nodes,nn1,nn2)
%
%   input
%     Elmts        : Element-Node table
%     Nodes        : Node coordinates
%     nn1          : number of face node 1
%     nn2          : number of face node 2
%
%   output
%     Elmts        : New Element-Node table
%     Nodes        : New Node coordinates

% Copyright, DHI, 2007-11-09. Author: JGR

err = 0;

% Check if nn1 and nn2 actually is a face
[E1,C1] = find(Elmts==nn1);
[E2,C2] = find(Elmts==nn2);
% Find elements sharing these two nodes
Eface = intersect(E1,E2);

% There should be two elements exactly.
if (numel(Eface) ~= 2)
  err = 1;
  return;
end

% Check that the two elements are triangles
if (size(Elmts,2) == 4)
  if (sum(Elmts(Eface,4)) > 0)
    err = 2;
    return;
  end
else
  % Make Elmts a mixed tri-quad mesh (adding a 4th column)
  Elmts(1,4) = 0;
end

% Find the node in each triangle that is not nn1 or nn2
En1 = Elmts(Eface(1),1:3);
En2 = Elmts(Eface(2),1:3);
n1 = En1(En1 ~= nn1 & En1 ~= nn2);
n2 = En2(En2 ~= nn1 & En2 ~= nn2);

% Make the quad
Eq = [n1 nn1 n2 nn2];

% Check if the quad is counter clockwise
ab = Nodes(Eq(2),1:2) - Nodes(Eq(1),1:2);  % edge vector corner a to b
ac = Nodes(Eq(4),1:2) - Nodes(Eq(1),1:2);  % edge vector corner a to c
area2 = ab(:,1).*ac(:,2)-ab(:,2).*ac(:,1);        % 2*Area (signed) of elements
% Reverse node order
if (area2 < 0)
  Eq([2 4]) = Eq([4 2]);
end

% Update first element, delete second.
Elmts(Eface(1),:) = Eq;
Elmts(Eface(2),:) = [];


