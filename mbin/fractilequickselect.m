function a = fractilequickselect(X,fraction)
%FRACTILEQUICKSELECT Calculates fractile of dataset.
%   A = FRACTILEQUICKSELECT(X,FRACTION) returns the FRACTILE fractile
%   of the dataset X.
%
%   Use FRACTILE(X,FRACTION) for a high level version that works on
%   rows/columns of a matrix. (TO BE IMPLEMENTED)
%
%   FRACTILEQUICKSELECT uses all data of X, independant of whether it is a
%   vector or a matrix. To find the fractile of the columns/rows of a
%   matrix X, the columns/rows must be supplied one at a time and the
%   result collected manually.
%
%   Note that FRACTILEQUICKSELECT will always return a value in the
%   dataset. If applying
%       b1 = fractilequickselect(a,0.5)
%       b2 = median(a)
%   this will only return the exact same result if there is an odd number
%   of elements in a. For a=1:5, the value 3 is returned for both methods.
%   For a=1:6, b1 will be 3 and b2 will be 3.5.
%
%   Example:
%       a = rand(5);
%       b = fractilequickselect(a,0.5);

% This Quickselect routine is based on the algorithm described in
% "Numerical recipes in C", Second Edition, Cambridge University Press,
% 1992, Section 8.5, ISBN 0-521-43108-5. Original code by Nicolas Devillard
% - 1998. Public domain. Modified to calculate fractiles and to be Matlab
% compatible, April 2008.

