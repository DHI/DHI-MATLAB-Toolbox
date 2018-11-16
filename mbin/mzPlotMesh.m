function H = mzPlotMesh(Elmts,Nodes,bccode,nono,elno)
%MZPLOTMESH Plot mesh.
%
%   Plots mesh, optionally including boundary node codes, and node and
%   element numbers.
%
%   Usage:
%       mzPlotMesh(Elmts,Nodes)
%       mzPlotMesh(Elmts,Nodes,bccode)
%       mzPlotMesh(Elmts,Nodes,bccode,nono,elno)
%
%   Inputs:
%       Elmts  : Element-Node table, for each element list the node number,
%                e.g., as returned by the delaunay function.
%       Nodes  : Node coordinates having 4 columns, [x, y, z, code]
%       bccode : Plot code boundaries (boolean)
%       nono   : Plot node numbers on each node (boolean)
%       elno   : Plot element numbers inside each element (boolean)
%
%   Note: For big meshes, plotting of node and element numbers will take
%   quite some time.

% Copyright, DHI, 2007-11-09. Author: JGR

if (nargin<3)
  bccode = 0;
end
if (nargin<4)
  nono = 0;
end
if (nargin<5)
  elno = 0;
end

fontsize = 8;

X = Nodes(:,1);
Y = Nodes(:,2);
Z = Nodes(:,3);
if (size(Nodes,2)==3)
  Code = zeros(size(X));
else
  Code = Nodes(:,4);
end

% Plot a flat 2D plot
H = mzPlot(Elmts,X,Y,Z);

if (bccode+elno+nono > 0)
  set(H,'facecolor','none','edgecolor','k')
end

% Plot boundary codes.
if bccode>0
  % Make wireframe plot
  codes = sort(unique(Code))';

  pcolors = ['*r';'*b';'*g';'dr';'db';'dg'];
  pcolori = 1;
  for ic = codes
    if ic
      I = (Code==ic);
      hold on
      plot(X(I),Y(I),pcolors(pcolori,:));
      hold off
      pcolori = pcolori+1;
    end
  end
end

% Plot element numbers
if elno>0
  for i = 1:size(Elmts,1)
    if (size(Elmts,2) == 3 || Elmts(i,4) == 0)
      I = [1,2,3];
    else
      I = [1,2,3,4];
    end
    Ht = text(mean(X(Elmts(i,I))),mean(Y(Elmts(i,I))),sprintf('%i',i));
    set(Ht,'HorizontalAlignment','center','fontsize',fontsize);
  end
end

% Plot node numbers
if nono>0
  for i = 1:size(Nodes,1)
    Ht = text(Nodes(i,1),Nodes(i,2),sprintf('%i',i));
    set(Ht,'HorizontalAlignment','center','fontsize',fontsize,'color',[1 0 0]);
  end
end

