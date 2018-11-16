function dm = removeItem(dm,itemno)
%DFSTSO/REMOVEITEM Remove item to file.
%
%   Removes item number itemno from file.
%
%   Usage:
%       removeItem(dfs,itemno)
%
%   Inputs:
%       dfs    : dfs object
%       itemno : Number of item to remove

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

% Check item argument
if (dm.TSO.Count == 0)
  error('dfsTSO:NoItemsDefined',...
    'File has currently no items defined');
end
if (~isscalar(itemno))
  error('dfsTSO:IndexError',...
    'Item number must be a scalar integer');
end
if (0 >= itemno)
  error('dfsTSO:IndexError',...
    'Item number must be positive, starting from 1');
end
if (itemno > dm.TSO.Count)
  error('dfsTSO:IndexError',...
    'Item number must be less than %i (number of items in file)',dm.TSO.Count);
end

dm.TSO.RemoveItem(dm.TSO.Item(itemno));