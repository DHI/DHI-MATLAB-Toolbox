function [area] = mzCalcElmtArea(Elmts,Nodes,geo,signed)
%MZCALCELMTAREA Calculate element area
%
%   Calculate area of element
%
%   Usage:
%     area = mzCalcElmtArea(Elmts,Nodes)
%     area = mzCalcElmtArea(Elmts,Nodes,signed)
%
%   Inputs:
%     Elmts  : Element table
%     Nodes  : Node coordinates, only [X Y] column needed.
%     geo    : If Nodes coordinates are geographical coordinates, set 
%              to 1 to calculate area in m^2 instead of deg^2. If not
%              set, geo = 0 is used.
%     signed : If set to 1, calculates signed area. If sign is negative
%              the element is clockwise and should be reversed. If not
%              set, signed = 0 is used.

% Copyright, DHI, 2007-11-09. Author: JGR

if (nargin < 3)
  geo = 0;
end
if (nargin < 4)
  signed = 0;
end

% Find all the quads
if (size(Elmts,2) == 3)
  hasquads = false;
else
  hasquads = true;
  quads = Elmts(:,4) > 0;
end

%% Calculate face vectors
ab = Nodes(Elmts(:,2),1:2)-Nodes(Elmts(:,1),1:2);   % edge vector corner a to b
ac = Nodes(Elmts(:,3),1:2)-Nodes(Elmts(:,1),1:2);   % edge vector corner a to c
if hasquads
  ad = zeros(size(ab));                             % edge vector corner a to d
  ad(quads,:) = Nodes(Elmts(quads,4),1:2)-Nodes(Elmts(quads,1),1:2); 
end

%% If geographical coordinates, make face vectors in meters, 
if (geo)
  earth_radius = 6366707;
  deg2rad      = pi/180;
  
  % Y on nodes
  Y     = Nodes(:,2);
  % Y on element centers
  Ye    = sum(Y(Elmts(:,1:3)),2);
  if (hasquads)
    Ye(quads) = Ye(quads) + Y(Elmts(quads,4));
    Ye    = Ye./(3+quads);
  else
    Ye    = Ye./3;
  end
  cosYe = cosd(Ye);
  
  ab(:,1) = (earth_radius*deg2rad) * ab(:,1).*cosYe;
  ab(:,2) = (earth_radius*deg2rad) * ab(:,2);
  ac(:,1) = (earth_radius*deg2rad) * ac(:,1).*cosYe;
  ac(:,2) = (earth_radius*deg2rad) * ac(:,2);
  if (hasquads)
    ad(:,1) = (earth_radius*deg2rad) * ad(:,1).*cosYe;
    ad(:,2) = (earth_radius*deg2rad) * ad(:,2);
  end
end

%% Areas
area = 0.5*(ab(:,1).*ac(:,2)-ab(:,2).*ac(:,1));  % area of triangles
if (hasquads)
  area(quads) = area(quads) + ...
    0.5*(ac(quads,1).*ad(quads,2)-ac(quads,2).*ad(quads,1)); 
end

if (~signed)
  area = abs(area);
end
