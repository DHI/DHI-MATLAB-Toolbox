function dm = addItem(dm,itemname,eumtype,eumunit,datatype)
%DFSTSO/ADDITEM Adds item to file.
%
%   Adds one item to file.
%
%   Usage:
%       addItem(dfs,itemname)
%       addItem(dfs,itemname,eumtype)
%       addItem(dfs,itemname,eumtype,eumunit)
%       addItem(dfs,itemname,eumtype,eumunit,datatype)
%
%   Inputs:
%       dfs      : DFS object
%       itemname : String containing the name of the item
%       eumtype  : String containing the name of the EUM Type
%                  If omitted, undefined is used.
%       eumunit  : String containing the name of the EUM Unit
%                  If omitted, undefined is used.
%       datatype : String containing the type of data to store in the file
%                  one of: 'Type_Float', 'Type_Double', 'Type_Char', 
%                          'Type_Int', 'Type_Unsigned', 'Type_Short', 
%                          'Type_Unsigned_Short'
%                  If omitted, 'Type_Float' is used.
%
%   Note:
%       eumtype must be a valid EUM Type string, see DFSTSO/listEumTypes
%       for a list of all valid strings.
%
%       eumunit must be a valid EUM Unit string matching the EUM Type, see
%       dfsTSO/listEumUnits for valid strings for a given item EUM type.
%
%       If unknown/incompatible types and units are given, the item will be
%       added, but type and unit will not be set, and a warning is issued.
%
%       Eum type and unit can be set/changed using dfsTSO/setItemEum.
%
%   See also DFSTSO/setItemEum, DFSTSO/listEumTypes, DFSTSO/listEumUnits
%

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

item = dm.TSO.NewItem;
item.name = itemname;
if (nargin < 5)
    item.DataType = 'Type_Float';
else
    item.DataType = datatype;
end

try
  if (nargin == 4)
    setItemEum(dm,dm.TSO.Count,eumtype,eumunit);
  elseif (nargin == 3)
    setItemEum(dm,dm.TSO.Count,eumtype);
  end
catch
  % Change error to warning - item already added.
  warning('dfsTSO:EUMError',...
    '%s\nUse setItemEum to set EUM type and unit for existing items'...
    ,lasterr)
end