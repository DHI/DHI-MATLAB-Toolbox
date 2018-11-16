function succes = close( dm )
%DFSTSO/CLOSE Close DFS file.
%
%   Close a dfsTSO object, and releases memory storage associated with
%   the object.
%
%       close( dfs )
%
%   NOTE: Remember to save the file by calling save(dfs) before closing. If
%   not, changes are discarded.

if (~isa(dm.TSO,dm.TSOPROGID))
  warning('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

dm.TSO.delete;
