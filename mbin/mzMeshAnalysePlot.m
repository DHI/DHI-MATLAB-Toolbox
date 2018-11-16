function [H] = mzMeshAnalysePlot(paxis,Elmts,Nodes,count,always,usecolor)
% MZMESHANALYSEPLOT  Special plot routine not plotting all elements
%
%   Plots only those within paxis, and only count elements at most.
%   All elements on the boundary are plotted (which may be more than
%   count), and also all elements listed in always.
%
%   Usage
%     mzMeshAnalysePlot(paxis,Elmts,Nodes,count,always)
%
%   Input
%     paxis   : [xmin xmax ymin ymax] axis limits
%     Elmts   : Element-Node table
%     Nodes   : Node coordinates
%     count   : max number of elements to plot
%     always  : list of element numbers always to plot (optional)

% Copyright, DHI, 2007-11-09. Author: JGR

X    = Nodes(:,1);
Y    = Nodes(:,2);
Z    = Nodes(:,3);
Z0   = zeros(size(Z));
code = Nodes(:,4);

if (numel(paxis) == 0)
  inpaxisn = true(size(code));
  inpaxis  = true(size(Elmts,1),1);
else
  % Find nodes within paxis
  inpaxisn = ...
    ((paxis(1) <= X) & (X <= paxis(2)) & ...
     (paxis(3) <= Y) & (Y <= paxis(4)) );
  % Find elements with node within paxis (only 1:3 !!!)
  inpaxis  = sum(inpaxisn(Elmts(:,1:3)),2) > 0;
end

% Limit elements to plot, always plot those on boundary (onbc)
if (count < nnz(inpaxis))
  % find nodes within paxis on boundary
  onbcn    = (code > 0) & inpaxisn;
  % find elements within paxis on boundary (only 1:3 !!!)
  onbc     = sum(onbcn(Elmts(:,1:3)),2) > 0;
  % Number of elements left to plot, always at least 100
  left     = max(count-nnz(onbc),100);
  % Elements within paxis not on boundary
  interior = inpaxis & ~onbc;
  % Select a number of those in interior to plot
  step     = max(ceil(nnz(interior)/left),1);
  I        = find(interior);
  interior = 0*interior;
  interior(I(1:step:end)) = 1;
  % If some elements must always be plotted
  if nargin >= 5
    interior(always) = 1;
    interior = interior & inpaxis;
  end
  % Plot those in interior, and all on boundary
  inpaxis  = interior | onbc;
end

% Plot
if (size(Elmts,2) == 3)
  d          = Elmts(inpaxis,[1 2 3 1])';
else
  quads      = Elmts(:,4) > 0;
  d          = Elmts(:,[1 2 3 1 1]);
  d(quads,:) = Elmts(quads,[1 2 3 4 1]);
  d          = d(inpaxis,:)';
end

if (~usecolor)
  H = plot(X(d),Y(d),'k');
else

  ax = newplot();
  H  = patch(X(d),Y(d),Z0(d),Z(d),...
  	  'facecolor','none','edgecolor','interp',...
  	  'facelighting', 'none', 'edgelighting', 'flat');
%     'parent',ax);
  
  %grid(ax,'on');
end

% Scale axis.
axis equal tight
if (numel(paxis) > 0)
  axis(paxis);
end

if nargout == 0
  clear H;
end

