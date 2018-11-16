function [Elmts,Nodes] = mzMeshCollapseElement(Elmts,Nodes,e)
% MZMESHCOLLAPSEELEMENT Collapses element in mesh
%
%   Collapsing the element to one node placed in the center of the element
%
%   Usage
%     [Elmts,Nodes] = mzMeshCollapseFace(Elmts,Nodes,e)
%
%   input
%     Elmts        : Element-Node table
%     Nodes        : Node coordinates
%     e            : Number of element to collapse
%
%   output
%     Elmts        : New Element-Node table
%     Nodes        : New Node coordinates

% Copyright, DHI, 2007-11-09. Author: JGR

X    = Nodes(:,1);
Y    = Nodes(:,2);
Z    = Nodes(:,3);
code = Nodes(:,4);

% Nodes used by element
N = Elmts(e,:);
% If triangle in a quad mesh, N(end)=0, remove the 0
if (N(end)==0)
  N = N(1:end-1);
end

% Delete collapsing element
Elmts(e,:) = [];

% Find element center coordinate (not bilinear for quads !!!)
xe    = mean(X(N));
ye    = mean(Y(N));
ze    = mean(Z(N));
codee = max(code(N));

% Node to use as collapsing node
nn1   = N(1);

% Renumber all occurences of N(2:end) to N(1)
for i=2:length(N)
  Elmts(Elmts==N(i)) = nn1;
end

% Count for each element how many times nn1 occurs
Ncount = sum(Elmts==nn1,2);
% If nn1 occurs more than once, the element is to be edited/deleted
Eface = find(Ncount > 1);

% Check which of these are quads
if (size(Elmts,2) == 4)
  quads = Elmts(Eface,4) > 0;
else
  quads = false(size(Eface));
end

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

% Reposition nn1 to element center
Nodes(nn1,:) = [xe ye ze codee];
% Delete N(2:end) in descending order (Nodes are reordered for every n)
Ns = sort(N(2:end),'descend');
for n = Ns
  [Elmts,Nodes] = mzMeshDeleteNode(Elmts,Nodes,n);
end

