function [area,face_lengths,angles,dt] = mzMeshProperties(Elmts,Nodes,s,h_min)
%MZMESHPROPERTIES Calculates properties of mesh.
%   Calculates properties of mesh.
%   
%   Inputs
%     Elmts        : Element-Node table
%     Nodes        : Node coordinates
%     s            : surface elevation (optional, default s=0)
%     h_min        : minimum water depth (optional, default h_min=1)
%
%   Output
%     area         : area of elements
%     face_lengths : Lengths of each face of the elements. First column
%                    is the face Elmts(:,[1,2]), second Elmts(:,[2,3]).
%     angles       : Internal angle of each element. First column is the
%                    angle at node Elmts(:,1), second Elmts(:,2).
%     dt           : dt limited by CFL condition (dx/dt = sqrt(g*h))


% Copyright, DHI, 2007-11-09. Author: JGR

if (nargin < 3)
  s     = 0;
end
if nargin < 4
  h_min = 1;
end

% Check if geographical coordinates
if  ( -90 < min(Nodes(:,2)) && max(Nodes(:,2)) <  90 &&...
     -180 < min(Nodes(:,1)) && max(Nodes(:,1)) < 180)
  geo = true;
else
  geo = false;
end

% gravity
g = 9.81;

% Z on nodes
Z = Nodes(:,3);

% Find all the quads
if (size(Elmts,2) == 3)
  hasquads = false;
  quads    = false(size(Elmts,1),1);
else
  hasquads = true;
  quads    = Elmts(:,4) > 0;
end

% Z on element centers
Zfn          = Z(Elmts(:,1:3));
if (hasquads)
  Zfn(quads,4) = Z(Elmts(quads,4));
end
Ze = sum(Zfn,2)./(3+quads);

% Water depth on elements
h = -Ze + s;
h = max(h,h_min);

% Calculate face vectors
ab = Nodes(Elmts(:,2),1:2)-Nodes(Elmts(:,1),1:2);   % edge vector corner a to b
ac = Nodes(Elmts(:,3),1:2)-Nodes(Elmts(:,1),1:2);   % edge vector corner a to c
bc = Nodes(Elmts(:,3),1:2)-Nodes(Elmts(:,2),1:2);   % edge vector corner b to c
if hasquads
  ad = zeros(size(ab));
  bd = zeros(size(ab));
  cd = zeros(size(ab));
  ad(quads,:) = Nodes(Elmts(quads,4),1:2)-Nodes(Elmts(quads,1),1:2); 
  bd(quads,:) = Nodes(Elmts(quads,4),1:2)-Nodes(Elmts(quads,2),1:2); 
  cd(quads,:) = Nodes(Elmts(quads,4),1:2)-Nodes(Elmts(quads,3),1:2); 
end

% Make vectors in meters, if geographical coordinates
if (geo)
  % E = lon*cos(lat)*Earth radius in meters
  earth_radius = 6366707;
  deg2rad      = pi/180;
  % Y on nodes
  Y     = Nodes(:,2);
  % Y on element centers
  Yfn   = Y(Elmts(:,1:3));
  if (hasquads)
    Yfn(quads,4) = Y(Elmts(quads,4));
  end
  Ye    = sum(Yfn,2)./(3+quads);
  cosYe = cosd(Ye);
  ab(:,1) = (earth_radius*deg2rad) * ab(:,1).*cosYe;
  ab(:,2) = (earth_radius*deg2rad) * ab(:,2);
  ac(:,1) = (earth_radius*deg2rad) * ac(:,1).*cosYe;
  ac(:,2) = (earth_radius*deg2rad) * ac(:,2);
  bc(:,1) = (earth_radius*deg2rad) * bc(:,1).*cosYe;
  bc(:,2) = (earth_radius*deg2rad) * bc(:,2);
  if (hasquads)
    ad(:,1) = (earth_radius*deg2rad) * ad(:,1).*cosYe;
    ad(:,2) = (earth_radius*deg2rad) * ad(:,2);
    bd(:,1) = (earth_radius*deg2rad) * bd(:,1).*cosYe;
    bd(:,2) = (earth_radius*deg2rad) * bd(:,2);
    cd(:,1) = (earth_radius*deg2rad) * cd(:,1).*cosYe;
    cd(:,2) = (earth_radius*deg2rad) * cd(:,2);
  end
end
area = 0.5*abs(ab(:,1).*ac(:,2)-ab(:,2).*ac(:,1));  % area of triangles
if (hasquads)
  area(quads) = area(quads) + ...
    0.5*abs(ac(quads,1).*ad(quads,2)-ac(quads,2).*ad(quads,1)); 
end

if (nargout == 1), return, end

% Length of faces (a opposing node A, i.e., bc)
lab = sqrt(sum(ab.^2,2));  % c
lac = sqrt(sum(ac.^2,2));  % b
lbc = sqrt(sum(bc.^2,2));  % a
if (hasquads)
  lad = sqrt(sum(ad.^2,2));
  lbd = sqrt(sum(bd.^2,2));
  lcd = sqrt(sum(cd.^2,2));
end

% Calculate face lengths
face_lengths = zeros(size(Elmts));
face_lengths(:,1) = lab;
face_lengths(:,2) = lbc;
if (hasquads)
  face_lengths(~quads,3) = lac(~quads);
  face_lengths(quads,3)  = lcd(quads);
  face_lengths(quads,4)  = lad(quads);
else
  face_lengths(:,3) = lac;
end

if (nargout == 2), return, end

% Calculate angles, first node in first column. For geo, this is not the
% "correct" angle
% a^2 = b^2 + c^2 - 2*b*c*cos(A)
angles = zeros(size(Elmts));
if (~hasquads)
  angles(:,1) = acosd((-lbc.^2+lac.^2+lab.^2)./(2*lac.*lab));
  angles(:,2) = acosd((-lac.^2+lab.^2+lbc.^2)./(2*lab.*lbc));
  angles(:,3) = acosd((-lab.^2+lbc.^2+lac.^2)./(2*lbc.*lac));
else
  I = ~quads;
  angles(I,1) = acosd((-lbc(I).^2+lac(I).^2+lab(I).^2)./(2*lac(I).*lab(I)));
  angles(I,2) = acosd((-lac(I).^2+lab(I).^2+lbc(I).^2)./(2*lab(I).*lbc(I)));
  angles(I,3) = acosd((-lab(I).^2+lbc(I).^2+lac(I).^2)./(2*lbc(I).*lac(I)));
  I = quads;
  angles(I,1) = acosd((-lbd(I).^2+lad(I).^2+lab(I).^2)./(2*lad(I).*lab(I)));
  angles(I,2) = acosd((-lac(I).^2+lab(I).^2+lbc(I).^2)./(2*lab(I).*lbc(I)));
  angles(I,3) = acosd((-lbd(I).^2+lbc(I).^2+lcd(I).^2)./(2*lbc(I).*lcd(I)));
  angles(I,4) = acosd((-lac(I).^2+lcd(I).^2+lad(I).^2)./(2*lcd(I).*lad(I)));
end
if (nargout == 3), return, end

% Calculate element "length" based on half triangle height
farea  = repmat(area,1,3);
length = farea./face_lengths(:,1:3);
if (hasquads)
  % Element "length" based on full quad height
  length(:,4)     = +inf;
  length(quads,4) = area(quads)./face_lengths(quads,4);
end
length = min(length,[],2);

% Calculate dt
dt = (length./(sqrt(g*h)));
dt(h==0) = +inf;

