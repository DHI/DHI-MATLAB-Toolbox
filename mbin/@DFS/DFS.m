function dm = DFS(a)
%DFS Create new DFS object for dfs files.
%
%   Opens a new DFS file using filename and returns an object for handling
%   the file.
%
%   Usage:
%      dfs = DFS( filename )
%
%   Inputs:
%      filename : name of file
%
%   Outputs:
%      dfs      : A matlab object holding the file

% Version 1, 2014-02-02, JGR

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

% Constants
dm.TIME_UNDEF       = 0;
dm.TIME_EQ_REL      = int32(DHI.Generic.MikeZero.DFS.TimeAxisType.TimeEquidistant);
dm.TIME_NONEQ_REL   = int32(DHI.Generic.MikeZero.DFS.TimeAxisType.TimeNonEquidistant);
dm.TIME_EQ_CAL      = int32(DHI.Generic.MikeZero.DFS.TimeAxisType.CalendarEquidistant);
dm.TIME_NONEQ_CAL   = int32(DHI.Generic.MikeZero.DFS.TimeAxisType.CalendarNonEquidistant);

if (nargin == 0)
  error('DFS:NoFileProvided','No filename provided.');
elseif (nargin >= 1 && ischar(a))
  filename = a;
elseif (nargin >= 1 && isa(a, 'DHI.Generic.MikeZero.DFS.IDfsFile'))
  dm.dfsFile = a;
  dm = class(dm,'DFS');
  return;
else
  error('DFS:WrongInput','Wrong input arguments');
end

% Validate existing file
if (exist(filename,'file') == 0)
  filename(filename=='\') = '/';
  error('DFS:FileNotFound',['The file was not found: ' filename])
end

dm.dfsFile  = DfsFileFactory.DfsGenericOpen(infile);

dm = class(dm,'DFS');

