function [x,y,z,ta] = mzReadxyz(filename)
%mzReadxyz Reads MikeZero .xyz file.
%
%   Read a MikeZero .xyz file.
%
%   Usage:
%       [xyz]      = mzReadxyz(filename)
%       [x,y,z]    = mzReadxyz(filename)
%       [xyz,ta]   = mzReadxyz(filename)
%       [x,y,z,ta] = mzReadxyz(filename)
%
%   Inputs:
%       filename : Name of file to write
%
%   Outputs:
%       xyz      : Coordinates of each point, matrix with 3 columns
%       x,y,z    : Coordinates of each point, column vectors
%       ta       : Text annotation following each coordinate. If no
%                  annotations exists in file, an empty cell array is
%                  returned. 
%
%   See also MZWRITEXYZ

% Copyright, DHI, 2007-11-09. Author: JGR
% Updated, 2008-05-07, JGR

% xyz file lines may have the following format:
%    x y z\n
%    x y z annotation text\n

if (nargout > 4)
  error('mzTool:mzReadxyz:nargout',...
        'Wrong number of output arguments');
end

fid    = fopen(filename,'rt');
if fid == -1
  error('mzTool:mzReadxyz:fileNotFound',['Could not find file: ' filename]);
end

binc   = 10000;
TAinc  = cell(binc,1);
XYZinc = zeros(binc,3);
TA     = TAinc;
XYZ    = XYZinc;
i      = 1;
XYZ    = [];
hasTA  = false;
while 1
  xyz = fscanf(fid,'%f %f %f%',3);
  if (length(xyz) ~= 3), break, end
  ta  = fgetl(fid);
  if ~ischar(ta), break, end
  if (length(ta) > 1)
    ta    = ta(2:end);
    hasTA = true;
  else 
    ta = '';
  end
  % Incrementing TA and XYZ in big chunks
  if (i>size(XYZ,1))
    TA  = [TA;TAinc];
    XYZ = [XYZ;XYZinc];
  end
  TA{i}    = ta;
  XYZ(i,:) = xyz;
  i = i+1;
end

fclose(fid);

% Remove unused allocated entries
XYZ = XYZ(1:i-1,:);
TA = TA(1:i-1);

if (~hasTA) 
  TA = {};
end

if (nargout <= 2)
  x  = XYZ;
  y  = TA;
else
  x  = XYZ(:,1);
  y  = XYZ(:,2);
  z  = XYZ(:,3);
  ta = TA;
end
