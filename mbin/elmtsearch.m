function k = elmtsearch(x,y,Elmts,xi,yi)
%ELMTSEARCH Enclosing element search.
%   T = ELMTSEARCH(X,Y,Elmts,XI,YI) returns the index of the enclosing
%   convex element for each point in XI,YI so that the enclosing element
%   for point (XI(k),YI(k)) is Elmts(T(k),:). ELMTSEARCH returns NaN for
%   all points not enclosed by an element. 
%
%   ELMTSEARCH handles triangles and general convex polygons. The elements
%   are defined as the triangels in tsearch, by a number of corner nodes.
%   Meshes with mixed convex polygons are allowed: Elmts has as many
%   columns as the polygon with the most nodes. At least the first 3
%   columns in Elmts must be non-zero, following columns can be zero,
%   example:
%
%   Elmts = [ 11 22 33 44 55;   % a pentagon
%             12 23 34 45  0;   % a quadrilateral
%             13 24 35  0  0;   % a triangle
%           ]
%
%   Each element must be convex. 
%
%   Compared to Matlabs TSEARCH, ELMTSEARCH does not require the elements
%   to cover the entire convex hull (as returned by DELAUNAY). ELMTSEARCH
%   works as expected for a domain with holes or concavities, and is almost
%   as fast as the Matlab TSEARCH
%
%   See also TSEARCH
