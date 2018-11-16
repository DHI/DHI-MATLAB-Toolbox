function [Elmts2,Nodes2] = mzRefineMesh(Elmts,Nodes,force)
%MZREFINEMESH Refine triangulated mesh, put node at center of faces.
%
%   Refine triangulated mesh. A new node will be put on every face in the
%   triangulation. The new mesh will contain exactly 4 times as many
%   elements. Elements will be ordered counter-clockwise.
%
%   This does presently not work optimal for mixed triangular/quadrilateral 
%   meshes (destroying all quads), hence you need to "force" it to be 
%   used in that case.
%
%   Usage:
%       [Elmts2,Nodes2] = mzRefineMesh(Elmts,Nodes)
%       [Elmts2,Nodes2] = mzRefineMesh(Elmts,Nodes,force)
%
%   Inputs:
%       Elmts : Element-Node table, for each element list the node number,
%               e.g., as returned by the delaunay function.
%       Nodes : Node coordinates having 4 columns, [x, y, z, code]
%       force : set to 1 to force refining a mesh with quads.
%
%   Outputs:
%       Elmts2 : Element-Node table, for each element list the node number,
%               e.g., as returned by the delaunay function.
%       Nodes2 : Node coordinates having 4 columns, [x, y, z, code]
%

% Copyright, DHI, 2007-11-09. Author: JGR
% Modified, 2011-10-12 JGR

if (nargin < 3 || force == 0)
  if (size(Elmts,2) > 3)
    error('mzTool:mzRefineMesh:NotTriangular',...
      ['mzRefineMesh only works for triangular meshes, not for mixed\n'...
       'triangular/quadrilateral meshes. Use the force argument to overrule']);
  end
end

if (size(Elmts,2) == 3)
  hasquads = false;
else
  hasquads = true;
  quads  = (Elmts(:,4) > 0);
end


% Create node-node connectivity matrix, 
m = size(Nodes,1);
if (~hasquads)
  I = [Elmts(:,1);Elmts(:,2);Elmts(:,3)];
  J = [Elmts(:,2);Elmts(:,3);Elmts(:,1)];
  NNconDir = sparse(I,J,ones(size(I)),m,m);
else
  I = [Elmts(:,1);Elmts(:,2);Elmts(quads,3);Elmts(quads,4);Elmts(~quads,3)];
  J = [Elmts(:,2);Elmts(:,3);Elmts(quads,4);Elmts(quads,1);Elmts(~quads,1)];
  NNconDir = sparse(I,J,ones(size(I)),m,m);
end
% Create lower triangular matrix i.e. edge from node a to b is the same 
% as from b to a: Add transpose and take the lower triangular part only - 
% then it is possible to reckognize internal (2) and boundary (1) edges/faces.
NNcon = tril(NNconDir+NNconDir');

% Extract coordinates of original mesh
X = Nodes(:,1);
Y = Nodes(:,2);
Z = Nodes(:,3);
codes = Nodes(:,4);

% For internal faces, find mid point
[n1,n2] = find(NNcon==2);
Nodes2 = 0.5*[ X(n1)+X(n2) , ...
               Y(n1)+Y(n2) , ...
               Z(n1)+Z(n2) , ...
               0*n1 ];

if (hasquads) 
  % Add all center element coordinates for quads
  I = find(quads);
  Nodes2q = [ sum(X(Elmts(I,:)),2)/4 , ...
              sum(Y(Elmts(I,:)),2)/4 , ...
              sum(Z(Elmts(I,:)),2)/4 , ...
              0*I ];
  Nodes2 = [Nodes2;Nodes2q];
end
           
% For boundary faces, find mid point
[n1,n2] = find(NNcon==1);
% Create boundary code vector
code3 = zeros(numel(n1),1);
% loop over all boundary faces
for i=1:numel(n1)
  if (codes(n1(i)) == 1 || codes(n2(i)) == 1)
    % If one of them is land (1), the new node is land
    code3(i) = 1;
  else
    % Check if face goes from n1 to n2 or reverse
    if (NNconDir(n1(i),n2(i)) ~= 0)
      % It goes from n1 to n2, use n2 code
      code3(i) = codes(n2(i));
    else
      % It goes from n2 to n1, use n1 code
      code3(i) = codes(n1(i));
    end
  end
end
Nodes3 =     [ 0.5*(X(n1)+X(n2)) , ... 
               0.5*(Y(n1)+Y(n2)) , ...
               0.5*(Z(n1)+Z(n2)) , ...
               code3 ];

% Constraints - boundary edges defined as two node references (numbers)
% For the original mesh this is [n1(:) n(:)]. In the new mesh a new
% node is set in between.
n3Start = size(Nodes,1)+size(Nodes2,1);
C = [ n1(:)  (1:numel(n1))'+n3Start ;
      (1:numel(n1))'+n3Start  n2(:) ];

% Collect new nodes and triangulate
Nodes2 = [Nodes;Nodes2;Nodes3];
dt = DelaunayTri(Nodes2(:,1)-Nodes2(1,1),Nodes2(:,2)-Nodes2(1,2), C);
inside = inOutStatus(dt);
Elmts2 = dt.Triangulation(inside,:);

% Reorder elements to be counter-clockwise
ab = Nodes2(Elmts2(:,2),:)-Nodes2(Elmts2(:,1),:);  % edge vector corner a to b
ac = Nodes2(Elmts2(:,3),:)-Nodes2(Elmts2(:,1),:);  % edge vector corner a to c
area2=ab(:,1).*ac(:,2)-ab(:,2).*ac(:,1);           % 2*Area (signed) of triangles
I = find(area2<0);
Elmts2(I,[2 3]) = Elmts2(I,[3 2]);
