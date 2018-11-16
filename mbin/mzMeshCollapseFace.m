function [Elmts,Nodes] = mzMeshCollapseFace(Elmts,Nodes,nn1,nn2)
% MZMESHCOLLAPSEFACE Collapses face in mesh
%
%   Collapsing the face defined by two nodes to one node positioned at
%   center of face.
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

% Check if nn1 and nn2 actually is a face
[E1,C1] = find(Elmts==nn1);
[E2,C2] = find(Elmts==nn2);
% Note, this is strictly not sufficient for a quad mesh (for diagonal)
Eface = intersect(E1,E2);

if (numel(Eface) == 0)
  error('mzTool:mzMeshCollapseFace:nodesNotAFace',...
  'Input nn1 and nn2 is not a face in the mesh');
end

if (size(Elmts,2) == 4)
  quads = Elmts(Eface,4) > 0;
else
  quads = false(size(Eface));
end

% Move all nn2 references to nn1 
Elmts(Elmts==nn2) = nn1;
% Edit quad elements to triangles
if (sum(quads) > 0)
  Efaceq = Eface(quads);
  for i = 1:length(Efaceq)
    % Look for nn1 duplicate
    J = find(Elmts(Efaceq(i),:) == nn1);
    % The first occurence of nn1
    j = J(1);
    % Shift Elmts left to overwrite first occurence
    Elmts(Efaceq(i),j:end-1) = Elmts(Efaceq(i),j+1:end);
    % Set last node to zero
    Elmts(Efaceq(i),end) = 0;
  end
end
% Delete triangular elements having this face
Elmts(Eface(~quads),:) = [];

% Set nn1 xyz coordinates to face center average
Nodes(nn1,1:3) = 0.5*(Nodes(nn1,1:3) + Nodes(nn2,1:3));
% Set nn1 code to max of nn1 and nn2
Nodes(nn1,4) = max(Nodes(nn1,4),Nodes(nn2,4));
% Delete node nn2 from mesh
[Elmts,Nodes] = mzMeshDeleteNode(Elmts,Nodes,nn2);
