function mzWritexyz(filename,x,y,z,ta)
%mzWritexyz Writes MikeZero .xyz file.
%
%   Write a MikeZero .xyz file.
%
%   Usage:
%       mzWritexyz(filename,xyz)
%       mzWritexyz(filename,x,y,z)
%       mzWritexyz(filename,xyz,ta)
%       mzWritexyz(filename,x,y,z,ta)
%
%   Inputs:
%       filename : Name of file to write
%       xyz      : Coordinates of each point, matrix with 3 columns
%       x,y,z    : Coordinates of each point, column vectors.
%       ta       : Text annotations for each point, cell array
%
%   See also MZREADXYZ

% Copyright, DHI, 2007-11-09. Author: JGR

hasTA = false;

% Check number of input arguments
if (2 > nargin || nargin > 5)
  error('mzTOOL:mzWritexyz:nargin',...
        'mzWritexyz requires 2 to 5 arguments\n');
end

% Check input arguments and copy them
if (nargin == 2 || nargin == 3)
  if (size(x,2) ~= 3)
    error('mzTOOL:mzWritexyz:argin',...
          ['mzWritexyz error in input arguments.\n'...
           '           (xyz argument must have 3 columns)\n']);
  end
  Nodes = x;
  if (nargin == 3)
    TA    = y;
    hasTA = true;
  end
else
  Nodes = [x,y,z];
  if (nargin == 5)
    TA    = ta;
    hasTA = true;
  end
end

if (hasTA && size(Nodes,1) ~= size(TA,1))
    error('mzTOOL:mzWritexyz:argin',...
          ['mzWritexyz error in input arguments.\n'...
           '           Vectors must have same lengths\n']);
end

% Open and write file
fid    = fopen(filename,'wt');
if (fid == -1)
  error('mzTOOL:mzWritexyz:fileWriteAccessDenied',...
        sprintf('File can not be opened for writing: %s\n',filename));
end

if (hasTA)
  for i = 1:size(Nodes,1)
    fprintf(fid,'%17.15g %17.15g %17.15g %s\n',Nodes(i,:),TA{i});
  end
else
  fprintf(fid,'%17.15g %17.15g %17.15g\n',Nodes');
end

fclose(fid);
