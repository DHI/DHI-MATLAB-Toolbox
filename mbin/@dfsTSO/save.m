function save( dm , force )
%DFSTSO/SAVE Save dfsTSO file.
%
%   save( dfs )
%
%   File is saved, modified/new data is written to disc.
%
%   Note: there is no undo functionality!

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

if (nargin == 1)
  force = 0;
end

filename = dm.TSO.Connection.FilePath;
if (~force && exist(filename,'file'))
  button = questdlg(sprintf('File %s exists!\nOverwrite?',filename),'File exists','Yes','Cancel','Cancel');
  if (strcmp(button,'Cancel'))
    return
  end
end

dm.TSO.Connection.Save;