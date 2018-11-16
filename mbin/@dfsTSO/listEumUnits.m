function l = listEumUnits(dm,itemno)
%DFSTSO/LISTEUMUNITS List EUM Units available for item.
%
%   List the EUM units that are available for this item, given the item EUM
%   type.
%
%   Usage:
%       l = listEumUnits(dfs,itemno)
%
%   Input:
%       dfs    : DFS object
%       itemno : Number of item to retrieve available units from
%
%   Output:
%       l      : A list of all available units (abbreviated)
%
%   See also DFSTSO/listEumTypes, DFSTSO/setItemEum

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

% Check item argument
if (dm.TSO.Count == 0)
  error('dfsTSO:NoItemsDefined',...
    'File has currently no items defined');
end
if (0 >= itemno)
  error('dfsTSO:IndexError',...
    'Item number must be positive, starting from 1');
end
if (itemno > dm.TSO.Count)
  error('dfsTSO:IndexError',...
    'Item number must be less than %i (number of items in file)',dm.TSO.Count);
end

l = dm.TSO.Item(itemno).GetEumUnitsAbbreviation;