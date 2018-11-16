function [Elmts,Nodes] = mzMeshDeleteNode(Elmts,Nodes,nn)
% MZMESHDELETENODE  Delete node from mesh.
%
%   usage
%     [Elmts,Nodes] = mzMeshDeleteNode(Elmts,Nodes,nn)
%
%   input
%     Elmts        : Element-Node table
%     Nodes        : Node coordinates
%     nn           : number of node to delete
%
%   output
%     Elmts        : New Element-Node table
%     Nodes        : New Node coordinates

% Copyright, DHI, 2007-11-09. Author: JGR

if (numel(nn)>1)
  warning('mzTool:mzMeshDeleteNode:notVectorizable',...
  'Input nn can not be a vector. Only removing first in vector');
  nn = nn(1);
end

if (nn > size(Nodes,1))
  error('mzTool:mzMeshDeleteNode:outOfRange',...
  'Input nn is larger than the number of nodes');
end

X = Nodes(:,1);
Y = Nodes(:,2);

% Find elements using node nn
[E,C] = find(Elmts==nn);
% Should not be necessary, but just in case
E = unique(E);

% Check if we found any elements
if (numel(E) > 0)

  % Find nodes that elements in E are using
  N = Elmts(E,:);
  % Remove repetitions
  N = unique(N(:));
  % Delete 0 from list (for mixed quad/tri meshes)
  N(N==0) = [];
  % Delete the nn node from N
  N(N==nn) = [];

  if (length(N) >= 3)
  
    % Node coordinates of N
    Xn = X(N);
    Yn = Y(N);

    % Triangulate these (local numbering), move towards (0,0) to avoid
    % delaunay problems
    Tn = delaunay(Xn-mean(Xn),Yn-mean(Yn));
    % Renumber nodes to global numbering
    Tn = N(Tn);

    % Remove elements not within E (in case of non-convex set of N)
    % Calculate element center coordinates for new triangulation En

    % In case only one element, it becomes a column vector.
    if (size(Tn) == [3 1])
      Tn = Tn';
      Xne = sum(X(Tn))/3;
      Yne = sum(Y(Tn))/3;
    else
      Xne = sum(X(Tn),2)/3;
      Yne = sum(Y(Tn),2)/3;
    end
    % Check if Elmts contains quads, then add 4th column
    if (size(Elmts,2) == 4)
      Tn(1,4) = 0;
    end

    % Check which centers is inside original E
    In = elmtsearch(X,Y,Elmts(E,:),Xne,Yne);
    % Those with NaN is outside, remove
    Tn(isnan(In),:) = [];
  else
    Tn = [];
  end
  
  % Remove E and add Tn
  Elmts(E,:) = [];
  Elmts = [Elmts;Tn];

end
  
% Remove nn from Nodes
Nodes(nn,:) = [];
% Renumber Elmts to new set of Nodes
I = Elmts > nn;
Elmts(I) = Elmts(I) - 1;


