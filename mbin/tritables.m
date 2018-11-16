function [NtoE,EtoE,B] = tritables(EtoN)
%TRITABLES Build connection tables for tri/quad meshes.
%
%   Build connectivity tables for triangulated/mixed
%   triangular/quadrilateral mesh.
%
%   Usages:
%       [NtoE]            = tritables(EtoN)
%       [NtoE,EtoE]       = tritables(EtoN)
%       [NtoE,EtoE,EtoNs] = tritables(EtoN)
%
%   Input:
%       EtoN  : for each element list adjacent node numbers,  e.g., as
%               returned by the delaunay function.
%   Output:
%       NtoE  : for each node list elements adjacent to node.
%       EtoE  : for each element list neighbouring elements.
%       EtoNs : A sparse matrix version of the input EtoN: If element i has
%               node j as its k'th local node, then EtoNs(i,j) = k .

nelmts = size(EtoN,1);
nnodes = max(EtoN(:));

if (size(EtoN,2) == 4);
  hasquads = true;
  quads    = (EtoN(:,4) > 0);
else
  hasquads = false;
  quads    = false(size(EtoN,1),2);
end

% Build Element-to-Node indeces 
e = (1:nelmts)';
u = ones(size(e));
I = [e;e;e];
J = EtoN(:,1:3); J = J(:);
K = [1*u;2*u;3*u];
if (hasquads)
  I = [I;e(quads)];
  J = [J;EtoN(quads,4)];
  K = [K;4*u(quads)];
end

% Make Node-to-Element table
NtoE  = zeros(nnodes,3);
count = zeros(nnodes,1);
for i = 1:length(I)
  count(J(i)) = count(J(i))+1;
  NtoE(J(i),count(J(i))) = I(i);
end

if (nargout >= 2)
  % Element-to-Node sparse matrix (include local node numbering)
  B = spconvert([I,J,K]);
  % Binary Element-to-Node sparse matrix
  A = double(B~=0); 

  % Build Element-to-Element table
  EN    = A*A';
  % Direct neighbours have value 2 in EN
  [I,J] = find(EN==2);
  EtoE  = zeros(nelmts,3);
  count = zeros(nelmts,1);
  % Populate EtoE table
  for i = 1:length(J)
    count(J(i)) = count(J(i))+1;
    EtoE(J(i),count(J(i))) = I(i); 
  end
end


