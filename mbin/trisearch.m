function k = trisearch(x,y,tri,xi,yi)
%TRISEARCH Enclosing triangle search.
%   T = TRISEARCH(X,Y,TRI,XI,YI) returns the index of the enclosing
%   triangle for each point in XI,YI so that the enclosing triangle for
%   point (XI(k),YI(k)) is TRI(T(k),:).  TRISEARCH returns NaN for all
%   points not enclosed by a triangle. 
%
%   Compared to Matlabs TSEARCH, TRISEARCH does not require the
%   triangulation to cover the entire convex hull (as returned by
%   DELAUNAY). TRISEARCH works as expected for triangulation with holes or
%   concavities, and is almost as fast as the Matlab TSEARCH
%
%   See also TSEARCH
