function H = mzPlot(Elmts,X,Y,varargin)
%MZPLOT 2/3D tri/quads surface plot.
%
%   Plots results for flexible mesh data types. Supports triangular meshes
%   and mixed triangular and quadrilateral meshes, in 2D (flat colored) or
%   3D.
%
%   Usage:
%       mzPlot(Elmts,x,y)                  % 2D mesh plot
%       mzPlot(Elmts,x,y,c)                % 2D plot
%       mzPlot(Elmts,x,y,z,c)              % 3D plot of 2D data
%       mzPlot(Elmts,x,y,c,nlayers,layer)  % 2D plot of 3D data
%       mzPlot(...,'propname',propval,...) % sets properties
%
%   Inputs:
%       Elmts  : Element-Node table, for each element list the node number,
%                e.g., as returned by the delaunay function.
%       x,y    : Node coordinates, column vector
%       z      : Value at nodes, column vector, same size as x and y
%       c      : Value to use as color. Value can be node or element center
%                based. c must either have size [numElmts,1] or the size of
%                x and y. For 3D plot if set [], then c = z is used.
%
%   mzPlot(...,'PropertyName',PropertyValue,...) sets the value of
%   the specified surface property.  Multiple property values can be set
%   with a single statement.

% Copyright, DHI, 2007-11-09. Author: JGR

% start of varargin properties
start = 1;

% 2D mesh plot
if (nargin == 3 || (nargin > 4 && ischar(varargin{1})))
  varargin{end+1} = 'facecolor';
  varargin{end+1} = 'none';
  varargin{end+1} = 'edgecolor';
  varargin{end+1} = 'k';
  Z    = [];
  C    = zeros(size(X));
  useZ = false;

% 2D plot
elseif (nargin == 4 || (nargin > 5 && ischar(varargin{2})) )
  Z     = [];
  C     = varargin{1};
  useZ  = false;
  start = 2;

% 3D plot of 2D data
elseif (nargin == 5 || (nargin > 6 && ischar(varargin{3})) )
  Z     = varargin{1};
  C     = varargin{2};
  if (numel(C) == 0)
    C = Z;
  end
  useZ  = true;
  start = 3;
  
% 2D plot of 3D data
elseif (nargin == 6 || (nargin > 7 && ischar(varargin{4})) && size(Elmts,2) > 5 )
  Z       = [];
  C       = varargin{1};
  useZ    = false;
  nlayers = varargin{2};
  layer   = varargin{3};
  start   = 4;

  % Take out element bottom node layer
  Elmts2D = Elmts((layer:nlayers:end)',1:3);
  if (size(Elmts,2) > 6)
    quads = Elmts(:,8) > 0;
    Elmts2D(quads,4) = Elmts(quads,4);
  end
  Elmts = Elmts2D;
  C = C((layer:nlayers:end)');
  
else
  error(id('NotEnoughInputs'),'Not enough input arguments');
end

% Prepare axis and plot
ax = axescheck(varargin{start:end});
ax = newplot(ax);

% If one-dimensional, make sure it is a column vector
if (size(Z,1)==1)
  Z = Z';
end
if (size(C,1)==1)
  C = C';
end

if (size(C,2)==1 && size(C,1)==size(Elmts,1))
  C_elmt_based = true;
else
  C_elmt_based = false;
end

% Only triangles
if     (size(Elmts,2)==3)

  NI = Elmts(:,[1 2 3 1])';
  if (C_elmt_based)
    CNI = C';              % element based values
  else
    CNI = C(NI);           % node based values
  end
  if (useZ)
    H = patch(X(NI),Y(NI),Z(NI),CNI,'parent',ax,varargin{start:end});
  else
    H = patch(X(NI),Y(NI),CNI,'parent',ax,varargin{start:end});
  end

% Mixed triangels/quads
elseif (size(Elmts,2)==4)

  I4       = (Elmts(:,4) > 0);
  NI       = Elmts(:,[1 2 3 1 1]);
  NI(I4,:) = Elmts(I4,[1 2 3 4 1]);
  NI       = NI';
  if (C_elmt_based)
    CNI = C';         % element based values
  else
    CNI = C(NI);      % node based values
  end
  if (useZ)
    H = patch(X(NI),Y(NI),Z(NI),CNI,'parent',ax,varargin{start:end});
  else
    H = patch(X(NI),Y(NI),CNI,'parent',ax,varargin{start:end});
  end

end

if ~ishold(ax), 
  
  grid(ax,'on');
  
  % Set X-Y axis equal
  daratio = get(gca,'dataaspectratio');
  daratio = [min(daratio(1:2))*[1 1] daratio(3)];
  set(gca,'dataaspectratio',daratio);

  % View from top in 2D plots
  if (useZ)
    view(3);
  else
    view(2);
  end

end

if nargout == 0
  clear H;
end

function str = id(str)
str = ['mzTool:mzPlot:' str];