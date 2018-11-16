function dm = setItemEum(dm,itemno,eumtype,eumunit)
%DFSTSO/SETITEMEUM Set EUM type and/or unit for item.
%
%   Set the EUM type and/or unit for an item.
%
%   Usage:
%       setItemEum(dfs,itemno,eumtype)          Set only type
%       setItemEum(dfs,itemno,[],eumunit)       Set only unit
%       setItemEum(dfs,itemno,eumtype,eumunit)  Set type and unit
%
%   Inputs:
%       dfs      : DFS object.
%       itemno   : Number of item to set.
%       eumtype  : String containing the name of the EUM Type.
%       eumunit  : String containing the name of the EUM Unit.
%
%    Note:
%       eumtype must be a valid EUM Type string, see DFSTSO/listEumTypes
%       for a list of all valid strings.
%       eumunit must be a valid EUM Unit string matching the EUM Type, see
%       DFSTSO/listEumUnits for valid strings for a given item EUM type.
%
%   See also DFSTSO/listEumTypes, DFSTSO/listEumUnits
%

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

item = dm.TSO.Item(itemno);

% Set EumType
if (~isempty(eumtype))
  v_eumtypes = lower(item.GetEumTypes);
  if (ischar(eumtype))
    eumtype_nr = find(strcmpi(v_eumtypes,eumtype));
    if (isempty(eumtype_nr))
      error('dfsTSO:EumTypeNameNotFound',[...
        'Could not find EUM Type name "%s". EUM Type not set\n'...
        'Please consult listEumTypes(dfs) for a list of valid EUM Type names'...
        ],eumtype);
      return;
    end
  else
    eumtype_nr = eumtype;
  end
  if (0 > eumtype_nr || eumtype_nr > length(v_eumtypes))
      error('dfsTSO:EumTypeOutOfRange',[...
        'EUM Type number is out of range: %s. EUM Type not set\n'...
        'The number can not be larger than the size of the list\n'...
        'produced by listEumTypes(dfs)'],eumtype_nr);
      return;
  end
  item.EumType = eumtype_nr;
end

% Set EumUnit
if (nargin >= 4 && ~isempty(eumunit))
  v_eumunits = item.GetEumUnitsAbbreviation;
  if (ischar(eumunit))
    % Try to find abbreviation
    eumunit_nr = find(strcmpi(v_eumunits,eumunit));
    % Try to find description
    if (isempty(eumunit_nr))
      v_eumunitdescr = item.GetEumUnits;
      eumunit_nr  = find(strcmpi(v_eumunitdescr,eumunit));
    end
    if (isempty(eumunit_nr))
      error('dfsTSO:EumTypeNameNotFound',[...
        'Could not find EUM Unit name "%s" for item of EUM type "%s".\n'...
        'EUM Unit not set. Please consult listEumUnits(dfs,itemno) for a \n'...
        'list of valid EUM Unit names for this EUM type'...
        ],eumunit,item.EumTypeDescription);
      return;
    end
  else
    eumunit_nr = eumunit;
  end
  if ((0 > eumunit_nr) || (eumunit_nr > length(v_eumunits)))
      error('dfsTSO:EumTypeOutOfRange',[...
        'EUM Unit number is out of range: %s. EUM Unit not set\n'...
        'The number can not be larger than the size of the list\n'...
        'produced by listEumUnits(dfs,itemno)'],eumtype_nr);
      return;
  end
  item.EumUnit = eumunit_nr;  
end
