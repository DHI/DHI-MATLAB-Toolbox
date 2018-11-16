function [Elmts,Nodes] = mzReorderMesh(Elmts,Nodes,dospy)
%MZREORDERMESH Reorder nodes and elements of mesh.
%
%   Renumber element and nodes, such that the bandwidth of the Node-Node 
%   and Element-Element connectivity matrix is minimized. 
%
%   The Reordering uses the reverse Cuthill-McKee algorithm
%
%   Usage:
%       [Elmts,Nodes] = mzReorderMesh(Elmts,Nodes)
%       [Elmts,Nodes] = mzReorderMesh(Elmts,Nodes,dospy)
%
%   Input/output:
%       Elmts : Element-Node table, for each element list the node number,
%               e.g., as returned by the delaunay function.
%       Nodes : Node coordinates having 4 columns, [x, y, z, code]
%       dospy : Plots spy plots of before and after (logical)

% Copyright, DHI, 2007-11-09. Author: JGR

if (nargin<3)
  dospy=0;
end

% Find quads
if (size(Elmts,2) > 3)
  hasquads = true;
  quads    = Elmts(:,4) > 0;
else
  hasquads = false;
  quads    = false(size(Elmts,1),1);
end

markersize = 1;
nelements  = size(Elmts,1);
nnodes     = size(Nodes,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reorder nodes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Calculate node connectivity (face information)
A1 = sparse(Elmts(:,1),Elmts(:,2),ones(nelements,1),nnodes,nnodes);
A2 = sparse(Elmts(:,2),Elmts(:,3),ones(nelements,1),nnodes,nnodes);
if (~hasquads)
  A3 = sparse(Elmts(:,3),Elmts(:,1),ones(nelements,1),nnodes,nnodes);
  A  = A1 | A2 | A3;
else
  A3 = sparse(Elmts(~quads,3),Elmts(~quads,1),ones(nnz(~quads),1),nnodes,nnodes);
  A4 = sparse(Elmts( quads,3),Elmts( quads,4),ones(nnz( quads),1),nnodes,nnodes);
  A5 = sparse(Elmts( quads,4),Elmts( quads,1),ones(nnz( quads),1),nnodes,nnodes);
  A  = A1 | A2 | A3 | A4 | A5;
end
A  = A+A';

% Plot connectivity
if (dospy>0) 
  subplot(2,2,1)
  spy(A,markersize);
  title('Nodes before')
end
[I,J] = find(A);
fprintf('Node connectivity bandwidth before    :%5i\n',max(I-J));
  
% Create reorder table
p  = symrcm(A);
%p  = symamd(A);

% Inverse reorder table
ip = 0*p;
i  = 1:length(p);
ip(p(i)) = i;

% Reorder nodes
Nodes    = Nodes(p,:);
% Renumber Elmt table
I        = Elmts > 0;
Elmts(I) = ip(Elmts(I));

% Calculate reordered connectivity (only needed for statistical purposes)
A1 = sparse(Elmts(:,1),Elmts(:,2),ones(nelements,1),nnodes,nnodes);
A2 = sparse(Elmts(:,2),Elmts(:,3),ones(nelements,1),nnodes,nnodes);
if (~hasquads)
  A3 = sparse(Elmts(:,3),Elmts(:,1),ones(nelements,1),nnodes,nnodes);
  A  = A1 | A2 | A3;
else
  A3 = sparse(Elmts(~quads,3),Elmts(~quads,1),ones(nnz(~quads),1),nnodes,nnodes);
  A4 = sparse(Elmts( quads,3),Elmts( quads,4),ones(nnz( quads),1),nnodes,nnodes);
  A5 = sparse(Elmts( quads,4),Elmts( quads,1),ones(nnz( quads),1),nnodes,nnodes);
  A  = A1 | A2 | A3 | A4 | A5;
end
A = A+A';

% Plot reordered connectivity
if (dospy>0)
  subplot(2,2,2)
  spy(A,markersize);
  title('Nodes after')
end
[I,J] = find(A);
fprintf('Node connectivity bandwidth after     :%5i\n',max(I-J));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Reorder Elements
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Elemnt to Element connectivity

% First create element node connectivity
En = [
  (1:nelements)' Elmts(:,1) ones(nelements,1);
  (1:nelements)' Elmts(:,2) ones(nelements,1);
  (1:nelements)' Elmts(:,3) ones(nelements,1);
  ];
if (hasquads)
  En = [ En; ...
    find(quads) Elmts(quads,4) ones(nnz(quads),1);
    ];
end
EN = spconvert(En);

% Element to element connectivity
A  = EN*EN';

% Plot connectivity
if (dospy>0)
  subplot(2,2,3)
  spy(A,markersize);
  title('Elements before')
end
[I,J] = find(A);
fprintf('Element connectivity bandwidth before :%5i\n',max(I-J));

% Create reorder table
p  = symrcm(A);
%p  = symamd(A);

% Reorder;
Elmts = Elmts(p,:);

% Create Elemnt to Element connectivity after reordering
if (hasquads)
  quads = Elmts(:,4) > 0;
end

% First create element node connectivity
En = [
  (1:nelements)' Elmts(:,1) ones(nelements,1);
  (1:nelements)' Elmts(:,2) ones(nelements,1);
  (1:nelements)' Elmts(:,3) ones(nelements,1);
  ];
if (hasquads)
  En = [ En; ...
    find(quads) Elmts(quads,4) ones(nnz(quads),1);
    ];
end
EN = spconvert(En);

% Element to element connectivity
A  = EN*EN';

% Plot reordered connectivity and mesh
if (dospy>0)
  subplot(2,2,4)
  spy(A,markersize);
  title('Elements after')
end
[I,J] = find(A);
fprintf('Element connectivity bandwidth after  :%5i\n',max(I-J));
