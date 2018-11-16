function [Elmts,Nodes] = mzMeshMoveNode(Elmts,Nodes,nn,xn,yn)
% MZMESHADDNODE  Moves node in mesh.
%
%   Moves a new node to a new position. Nodes in the interior get a new z
%   value based on interpolation of existing elements. 
%
%   Note: The element connectivity is not updated, hence moving the node
%   inside another element will invalidate the mesh.
%
%   usage
%     [Elmts,Nodes] = mzMeshAddNode(Elmts,Nodes,nn,xn,yn)
%
%   input
%     Elmts        : Element-Node table
%     Nodes        : Node coordinates
%     nn           : number of node to move
%     xn           : new x coordinate of node
%     xn           : new y coordinate of node
%
%   output
%     Elmts        : New Element-Node table
%     Nodes        : New Node coordinates

% Copyright, DHI, 2007-11-09. Author: JGR

X = Nodes(:,1);
Y = Nodes(:,2);
Z = Nodes(:,3);

E = elmtsearch(X,Y,Elmts,xn,yn);

% Interpolate new z value
if (isnan(E))
  % Outside domain, use existing z
  zn = Nodes(nn,3);

else
  % Inside domain, interpolate a z value
  % Check if E is a quad
  if (size(Elmts,2) == 3)
    I = [1 2 3];
  else
    if (Elmts(E,4) == 0) 
      I = [1 2 3];
    else
      I = [3 4;
           1 2];
    end
  end
  % Element nodes
  en = Elmts(E,:);
  en = en(I);
  % coordinates for these nodes
  Xs = X(en);
  Ys = Y(en);
  Zs = Z(en);
  % Interplate zn for xn,yn (not bilinear for quads !!!)
  zn = griddata(Xs,Ys,Zs,xn,yn);
end

Nodes(nn,1) = xn;
Nodes(nn,2) = yn;
Nodes(nn,3) = zn;
