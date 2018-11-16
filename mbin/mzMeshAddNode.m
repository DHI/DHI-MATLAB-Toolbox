function [Elmts,Nodes,err] = mzMeshAddNode(Elmts,Nodes,xn,yn,allowbcnode)
% MZMESHAddNODE  Adds node from mesh
%
%   Adds a new node to the mesh. Nodes in the interior are added directly.
%   Nodes on the boundary are added by using a (xn,yn) just outside the
%   domain close to the face where node is to be placed, and the node is
%   placed on the center of the face.
%   
%   The z value is interpolated using surrounding nodes.
%
%   usage
%     [Elmts,Nodes,err] = mzMeshAddNode(Elmts,Nodes,xn,yn,allowbcnode)
%
%   input
%     Elmts        : Element-Node table
%     Nodes        : Node coordinates
%     xn           : x coordinate of new node
%     xn           : y coordinate of new node
%     allowbcnode  : Allow adding nodes on the boundary 
%                    (opional, default = 0)
%
%   output
%     Elmts         : New Element-Node table
%     Nodes         : New Node coordinates
%     err           : Zero on succes, 1 on failure
%

% Copyright, DHI, 2007-11-09. Author: JGR

if nargin < 5
  allowbcnode = 0;
end

err = 0;

X = Nodes(:,1);
Y = Nodes(:,2);
Z = Nodes(:,3);

if (size(Elmts,2) == 3)
  hasquads = false;
  quads    = false(size(Elmts,1),1);
else
  hasquads = true;
  quads    = Elmts(:,4) > 0;
end

E = elmtsearch(X,Y,Elmts,xn,yn);

exterior = isnan(E);

% (xn,yn) is not in the interior if E == NaN
if (exterior && ~allowbcnode)
  error('mzTool:mzMeshDeleteNode:notInteriorNode',...
        'Node is not in the interior of existing mesh');
      
% Add a new face node, if possible
elseif (exterior)
  % Find the face closest to (xn,yn)
  eid = (1:size(Elmts,1))';
  FN =     Elmts(:,[1,2]);
  FN = [FN;Elmts(:,[2,3])];
  FE = eid;
  FE = [FE;eid];
  if (~hasquads)
    FN = [FN;Elmts(:,[3,1])];
    FE = [FE;eid];
  else
    FN = [FN;Elmts(~quads,[3,1])];
    FN = [FN;Elmts(quads,[3,4])];
    FN = [FN;Elmts(quads,[4,1])];
    FE = [FE;eid(~quads)];
    FE = [FE;eid(quads)];
    FE = [FE;eid(quads)];
  end
  % Face center coordinates
  FX = 0.5*sum(X(FN),2);
  FY = 0.5*sum(Y(FN),2);
  % Minimum distance (squared)
  [dist,fn] = min((FX-xn).^2+(FY-yn).^2);
  % Length of face (squared)
  facelen = (X(FN(fn,1)) - X(FN(fn,2)))^2 + (Y(FN(fn,1)) - Y(FN(fn,2)))^2;
  % If (xn,yn) is "to far away", do nothing
  if (dist > 0.25*facelen), err = 1; return, end
  % Element number
  E    = FE(fn);
  % Move coordinate to center of face
  xn   = 0.5*(X(FN(fn,1)) + X(FN(fn,2)));
  yn   = 0.5*(Y(FN(fn,1)) + Y(FN(fn,2)));
  zn   = 0.5*(Z(FN(fn,1)) + Z(FN(fn,2)));
  % Code is always the last on the face, or 1 if one of the face codes is 1
  code = Nodes(FN(fn,2),4);
  if (Nodes(FN(fn,1),4) == 1 || Nodes(FN(fn,2),4) == 1)
    code = 1;
  end
else 
  code = 0;
end

% Element nodes
en = Elmts(E,:);
% If triangel element in mixed mesh, en(end) = 0, delete it
if (hasquads && ~quads(E))
  en(end) = [];
end

% coordinates for these nodes
Xs = X(en);
Ys = Y(en);
Zs = Z(en);

% Interplate zn for xn,yn for internal nodes
if (~exterior)
  zn = griddata(Xs,Ys,Zs,xn,yn);
end

% Add new node to end of list
Nodes(end+1,:) = [xn,yn,zn,code];
X = [X;xn];
Y = [Y;yn];
%Z = [Z;zn];

% Find all elements neighbouring of E (2 nodes in common)
E = zeros(size(Elmts,1),1);
for nn = en
  E = E + sum(Elmts==nn,2);
end
E = find(E >= 2);

% Check if we found any elements (should always happen)
if (numel(E) > 0)

  % Find nodes that elements in E are using
  N = Elmts(E,:);
  % Remove repetitions
  N = unique(N(:));
  % Delete 0 from list (for mixed quad/tri meshes)
  N(N==0) = [];
  % Add new node
  N = [N;size(Nodes,1)];

  % Node coordinates of N
  Xn = X(N);
  Yn = Y(N);
  
  % Triangulate these (local numbering), move towards (0,0) to avoid
  % delaunay problems
  Tn = delaunay(Xn-mean(Xn),Yn-mean(Yn));
  % Renumber nodes to global numbering
  Tn = N(Tn);

  % In case only one element, it becomes a column vector.
  if (size(Tn) == [3 1])
    Tn = Tn';
  end

  % Remove elements not within E (in case of non-convex set of N)
  % Calculate element center coordinates for new triangulation En
  Xne = sum(X(Tn),2)/3;
  Yne = sum(Y(Tn),2)/3;
  % Check which centers is inside original E
  In = elmtsearch(X,Y,Elmts(E,:),Xne,Yne);
  % Those with NaN is outside, remove
  Tn(isnan(In),:) = [];

  % For mixed meshes, add a 4th column
  if (numel(Tn) > 0 && hasquads)
    Tn(1,4) = 0;
  end
  
  % Remove E and add Ep
  Elmts(E,:) = [];
  Elmts = [Elmts;Tn];

end
  
