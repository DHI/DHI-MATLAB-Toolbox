function [dCdx,dCdy] = mzCalcGradient(Elmts,X,Y,C,area)
%MZCALCGRADIENT Calculate gradient.
%
%   Calculate the gradient of C.
%
%   Usage:
%     [dCdx,dCdy] = mzCalcGradient(Elmts,X,Y,C)
%     [dCdx,dCdy] = mzCalcGradient(Elmts,X,Y,C,area)
%
%   Inputs:
%     Elmts  : Element table.
%     X      : Node X coordinates
%     Y      : Node Y coordinates
%     C      : Node or element based values. If C is element based
%              an interpolation to node based values will take place.
%     area   : area of elements. If not given, area is calculated.
%
%   Outputs:
%     dCdx   : The x gradient of C
%     dCdy   : The y gradient of C

% Copyright, DHI, 2007-11-09. Author: JGR

Nodes = [X Y];

if (nargin < 5)
  area = mzCalcElmtArea(Elmts,Nodes);
end  

% Find all the quads
if (size(Elmts,2) == 3)
  hasquads = false;
else
  hasquads = true;
  quads = Elmts(:,4) > 0;
end

% Check if we have element based data, if so, interpolate to nodes.
if (numel(C) == size(Elmts,1))
  % Interpolate from element center to node values
  C = mzCalcNodeValues(Elmts,X,Y,C);
end

% Only triangles
if (~hasquads)
  dCdx1 = C(Elmts(:,1)) .* (Y(Elmts(:,3))-Y(Elmts(:,2)));
  dCdx2 = C(Elmts(:,2)) .* (Y(Elmts(:,1))-Y(Elmts(:,3)));
  dCdx3 = C(Elmts(:,3)) .* (Y(Elmts(:,2))-Y(Elmts(:,1)));
  dCdx  = -(dCdx1 + dCdx2 + dCdx3) ./ (2*area);

  dCdy1 = C(Elmts(:,1)) .* (X(Elmts(:,3))-X(Elmts(:,2)));
  dCdy2 = C(Elmts(:,2)) .* (X(Elmts(:,1))-X(Elmts(:,3)));
  dCdy3 = C(Elmts(:,3)) .* (X(Elmts(:,2))-X(Elmts(:,1)));
  dCdy  = (dCdy1 + dCdy2 + dCdy3) ./ (2*area);

% Mixed triangles and quads
else
  T = ~quads;
  Q = quads;

  dCdx = zeros(size(Elmts,1),1);
  dCdy = zeros(size(Elmts,1),1);

  % All the triangles
  dCdx1   = C(Elmts(T,1)) .* (Y(Elmts(T,3))-Y(Elmts(T,2)));
  dCdx2   = C(Elmts(T,2)) .* (Y(Elmts(T,1))-Y(Elmts(T,3)));
  dCdx3   = C(Elmts(T,3)) .* (Y(Elmts(T,2))-Y(Elmts(T,1)));
  dCdx(T) = -(dCdx1 + dCdx2 + dCdx3) ./ (2*area(T));

  dCdy1   = C(Elmts(T,1)) .* (X(Elmts(T,3))-X(Elmts(T,2)));
  dCdy2   = C(Elmts(T,2)) .* (X(Elmts(T,1))-X(Elmts(T,3)));
  dCdy3   = C(Elmts(T,3)) .* (X(Elmts(T,2))-X(Elmts(T,1)));
  dCdy(T) = (dCdy1 + dCdy2 + dCdy3) ./ (2*area(T));

  % All the quads
  dCdx1   = (C(Elmts(Q,4))-C(Elmts(Q,2))) .* (Y(Elmts(Q,3))-Y(Elmts(Q,1)));
  dCdx2   = (C(Elmts(Q,1))-C(Elmts(Q,3))) .* (Y(Elmts(Q,4))-Y(Elmts(Q,2)));
  dCdx(Q) = -(dCdx1 + dCdx2) ./ (2*area(Q));

  dCdy1   = (C(Elmts(Q,4))-C(Elmts(Q,2))) .* (X(Elmts(Q,3))-X(Elmts(Q,1)));
  dCdy2   = (C(Elmts(Q,1))-C(Elmts(Q,3))) .* (X(Elmts(Q,4))-X(Elmts(Q,2)));
  dCdy(Q) = (dCdy1 + dCdy2) ./ (2*area(Q));

end
