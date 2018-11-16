function t = mzTriangulateElmtCenters(x,y,EtoN)
%MZTRIANGULATEELMTCENTERS Triangulate element centers.
%
%   Triangulate (using delaunay) element centers, removing elements from
%   triangulation when the original elements does not share a node.
%
%   Usage:
%      t = mzTriangulateElmtCenters(x,y,EtoN)
%
%   Input:
%      x     : element center x coordinates.
%      y     : element center y coordinates.
%      EtoN  : triangulation matrix of elements.
%
%   Output:
%      t     : A triangulation matrix for the mesh using element centers as
%              nodes

% Copyright, DHI, 2007-11-09. Author: JGR

% triangulate element centers
t = delaunay(x,y);

% Remove elements from t when there are faces between elements where
% the elements do not share a node

% Safe but slightly slow version (though usually faster than delaunay)

% Create connectivity tables.
[NtoE,EtoE,B] = tritables(EtoN);
A  = double(B~=0);

% Element-to-element table, listing the number of noces that two elements
% share, i.e. if e1 and e2 are neighbours (share a face) then EN(e1,e2) =
% 2, if e1 and e2 just share a node EN(e1,e2) = 1. EN(e1,e1) = 3.
EN = A*A';

ok = true(size(t,1),1);

for i = 1:size(t,1) % for each element
  for j = 1:3       % for each face in element
    % Start/end node (= elements in original mesh) of face
    e1 = t(i,j);
    e2 = t(i,mod(j,3)+1);
    % Check if elements e1 and e2 in original mesh share a node
    if (~EN(e1,e2))
      % They do not share a nodeso remove this element
      ok(i) = false;
      break;
    end
  end
end

t = t(ok,:);

