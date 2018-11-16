function [xe,ye,ze] = mzCalcElmtCenterCoords(Elmts,X,Y,Z)
%MZCALCELMTCENTERCOORDS Calculate element center coordinates.
%
%   Calculate element center coordinates, averaging each of the values
%
%   Usage:
%     [xe,ye]    = mzCalcElmtCenterCoords(Elmts,X,Y)
%     [xe,ye,ze] = mzCalcElmtCenterCoords(Elmts,X,Y,Z)
%
%   Inputs:
%     Elmts  : Element table.
%     X      : Node X coordinates
%     Y      : Node Y coordinates
%     Z      : Node Z coordinates
%
%   Outputs:
%     xe     : element center x coordinate
%     ye     : element center y coordinate
%     ze     : element center z coordinate

% Copyright, DHI, 2010-08-20. Author: JGR

if (size(Elmts,2) == 3) 
    % The fast way, if all elements have 3 nodes
    xe = mean(X(Elmts),2); 
    ye = mean(Y(Elmts),2); 
    if (nargin >= 4)
        ze = mean(Z(Elmts),2);
    end
else
    % The manual way.
    xe = zeros(size(Elmts,1),1); 
    ye = zeros(size(Elmts,1),1); 
    if (nargin >= 4)
        ze = zeros(size(Elmts,1),1); 
    end
    for i=1:size(Elmts,1)
        % remove columns with 0 or negative node value
        elmt = Elmts(i,:);
        elmt = elmt(elmt>0);  
        xe(i) = mean(X(elmt),2); 
        ye(i) = mean(Y(elmt),2); 
        if (nargin >= 4)
            ze(i) = mean(Z(elmt),2);
        end
    end
end
