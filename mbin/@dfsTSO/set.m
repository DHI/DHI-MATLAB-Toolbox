function val = set(dm,varargin)
%DFSTSO/SET Set dfsTSO properties.
%
%   Set a property of a dfsTSO object.
%
%   You can not set all properties that can be retrieved by get. Try
%       a = set(dfs)
%   to see which properties can be set.
%
%   Usage:
%       val = set(dfs,'prop')       Retrieve value for property
%       set(dfs,'prop',val,...)     Set value for property
%       a = set(dfs)                Retrieve all property value pairs
%       set(dfs,a)                  Set all property value pairs
%
%   Note: 
%       Changes are first made to the file when save(dfs) is issued.
%
%   See also set, DFSTSO/GET

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

props = {};
vals  = {};

%% Print all setable properties
if nargin == 1

  % File properties
  val.FileName   = dm.TSO.Connection.FilePath;
  val.FileTitle  = dm.TSO.Connection.FileTitle;

  % Item properties
  for i=1:dm.TSO.Count
    val.ItemNames{i}         = dm.TSO.Item(i).Name;
    val.ItemValueTypes{i}    = dm.TSO.Item(i).ValueType;
    val.ItemCoordinates(i,1) = dm.TSO.Item(i).Origin.x;
    val.ItemCoordinates(i,2) = dm.TSO.Item(i).Origin.y;
    val.ItemCoordinates(i,3) = dm.TSO.Item(i).Origin.z;
  end

  % Time properties
  val.TimeAxisType = dm.TSO.Time.TimeType;
  if (dm.TSO.Time.IsCalendar)
    val.StartDate = parseDatetimeString(dm.TSO.Time.StartTime);
  else
    val.StartDate = dm.TSO.Time.StartTime;
  end
  val.TimeStep = [
      dm.TSO.Time.TimeStep.Year,...
      dm.TSO.Time.TimeStep.Month,...
      dm.TSO.Time.TimeStep.Day,...
      dm.TSO.Time.TimeStep.Hour,...
      dm.TSO.Time.TimeStep.Minute,...
      dm.TSO.Time.TimeStep.Second + ...
      dm.TSO.Time.TimeStep.Millisecond/1000
    ]; 

  % File properties
  val.DeleteValue = dm.TSO.DeleteValue;

  if nargout == 0 
    disp(val);
    clear dm;
  end

%% Handle input arguments
elseif (nargin == 2)
  
  % Read props and vals from structure
  if (isstruct(varargin{1}))
    A = varargin{1};
    props = fieldnames(A);
    for i = 1:length(props)
      vals{i} = (A.(props{i}));
    end
    
  % Property string, return value
  elseif (ischar(varargin{1}))
    val = get(dm,varargin{1});
    return;

  else
    error('dfsTSO:UknownPropertyArgument',...
      'Second argument to set is of wrong type.')
  end

else

  % Read property-value pairs
  ip = 0;
  propertyArgIn = varargin;
  while length(propertyArgIn) >= 2,
    ip = ip+1;
    props{ip}     = propertyArgIn{1};
    vals{ip}      = propertyArgIn{2};
    propertyArgIn = propertyArgIn(3:end);
  end
end

%% Set property values
for ip = 1:length(props)
  prop = props{ip};
  val  = vals{ip};

  switch lower(prop)

    case 'filename'
      dm.TSO.Connection.FilePath = val;

    case 'filetitle'
      dm.TSO.Connection.FileTitle = val;

    % Item properties
    case 'itemnames'
      if (length(val) ~= dm.TSO.Count)
        error('dfsTSO:ItemNamesWrongSize',[...
          'Value must contain one row for each item']);
      end
      for i=1:dm.TSO.Count
        dm.TSO.Item(i).Name = val{i};
      end

    case 'itemvaluetypes'
      if (length(val) ~= dm.TSO.Count)
        error('dfsTSO:ItemValueTypeWrongSize',[...
          'Value must contain one row for each item']);
      end
      I = zeros(dm.TSO.Count,1);
      for i=1:dm.TSO.Count
        I(i) = find(strcmpi(dm.ITEMVALUETYPES,val{i}));
        if (isempty(I(i)))
          sstr = sprintf('\n   %s',dm.ITEMVALUETYPES{:});
          error('dfsTSO:ITEMVALUETYPES',...
            'Unknown item value type: "%s". Must be one of:%s',val{i},sstr);
        end
      end
      for i=1:dm.TSO.Count
        dm.TSO.Item(i).ValueType = dm.ITEMVALUETYPES{I(i)};
      end

    case 'itemcoordinates'
      if (size(val,1) ~= dm.TSO.Count || size(val,2) ~= 3)
        error('dfsTSO:ItemCoordinateWrongSize',[...
          'Coordinates must have 3 columns containing x, y and z coordinates\n'...
          'and one row for each item']);
      end
      for i=1:dm.TSO.Count
        dm.TSO.Item(i).Origin.x = val(i,1);
        dm.TSO.Item(i).Origin.y = val(i,2);
        dm.TSO.Item(i).Origin.z = val(i,3);
      end

  % Time properties
      case 'startdate'
      if (dm.TSO.Time.IsCalendar)
        if (length(val) == 6)
          dm.TSO.Time.StartTime = COM.date(val(1),val(2),val(3),val(4),val(5),val(6));
        else
          error('dfsTSO:StartTimeError',...
            'Start time for a calendar time axis must be a datevec')
        end
      else
        dm.TSO.Time.StartTime = val;
      end

    case 'timeaxistype'
      I = find(strcmpi(dm.TIMEAXISTYPES,val));
      if (isempty(I))
        sstr = sprintf('\n   %s',dm.TIMEAXISTYPES{:});
        error('dfsTSO:TimeAxisTypeUnknown',...
          'Unknown time axis type: "%s". Must be one of:%s',val,sstr);
      end
      oldI = find(strcmpi(dm.TIMEAXISTYPES,dm.TSO.Time.TimeType));
      dm.TSO.Time.TimeType = dm.TIMEAXISTYPES{I};
      % If changing from relative to calendar, set new start time
      if (oldI <= 3 && I > 3)
        nowvec = datevec(now);
        dm.TSO.Time.StartTime = COM.date(nowvec(1),nowvec(2),nowvec(3));
      end

    case 'timestep'
      if (length(val) ~= 6)
        error('dfsTSO:TimestepWrongFormat',[...
          'The time step time must come in a datevec']);
      end
      dm.TSO.Time.TimeStep.Year        = val(1);
      dm.TSO.Time.TimeStep.Month       = val(2);
      dm.TSO.Time.TimeStep.Day         = val(3);
      dm.TSO.Time.TimeStep.Hour        = val(4);
      dm.TSO.Time.TimeStep.Minute      = val(5);
      %dm.TSO.Time.TimeStep.Second      = floor(val(6));
      %dm.TSO.Time.TimeStep.Millisecond = floor((val(6)-floor(val(6)))*1000);

      % The Second property is a ushort, max value of 32767, hence it will
      % not handle second values above that. Using Value property instead
      % It is a common use just to set seconds, and nothing else, i.e.
      % to get a timestep of one day, use [0,0,0,0,0,86400].
      % Large value (above 32767) is only supported for seconds
      
      % Set second and millisecond to zero, to remove existing values
      dm.TSO.Time.TimeStep.Second      = 0;
      dm.TSO.Time.TimeStep.Millisecond = 0;
      % Add seconds to Value instead
      if (strcmp('second',dm.TSO.Time.EumUnitDescription))
        dm.TSO.Time.TimeStep.Value = dm.TSO.Time.TimeStep.Value + val(6);
      elseif (strcmp('minute',dm.TSO.Time.EumUnitDescription))
        dm.TSO.Time.TimeStep.Value = dm.TSO.Time.TimeStep.Value + val(6)/60;
      elseif (strcmp('hour',dm.TSO.Time.EumUnitDescription))
        dm.TSO.Time.TimeStep.Value = dm.TSO.Time.TimeStep.Value + val(6)/3600;
      elseif (strcmp('day',dm.TSO.Time.EumUnitDescription))
        dm.TSO.Time.TimeStep.Value = dm.TSO.Time.TimeStep.Value + val(6)/(24*3600);
      else % Unknown time unit, use the Seconds property anyway
        dm.TSO.Time.TimeStep.Second      = floor(val(6));
        dm.TSO.Time.TimeStep.Millisecond = floor((val(6)-floor(val(6)))*1000);
      end


    % File properties
    case 'deletevalue'
      dm.TSO.DeleteValue = val;

    otherwise
      error(['dfsTSO property ' prop ' does not exist'])
      
  end
  
  clear val;

end
