function val = get(dm, propName)
%DFSTSO/GET Get dfsTSO properties.
%
%   Get properties from the specified object and return the value
%
%   Use set(dfs) to see which property values can be set, and how to set
%   them.
%
%   Usage:
%       get(dfs)            :  prints all get'able properties
%       a = get(dfs)        :  retrieves all get'able properties
%       a = get(dfs,'prop') :  retrieves property named 'prop'
%
%   See also DFSTSO/SET

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

%% Get time information from file.
if (dm.TSO.Time.IsCalendar)
  datetime = [
    parseDatetimeString(dm.TSO.Time.StartTime);
    parseDatetimeString(dm.TSO.Time.EndTime)];
else
  datetime = [dm.TSO.Time.StartTime;dm.TSO.Time.EndTime];
end
% Get timestep information from file.
if (strcmp(dm.TSO.Time.TimeType,'Equidistant_Calendar') || ...
    strcmp(dm.TSO.Time.TimeType,'Equidistant_Relative'))
  if (strcmp('second',dm.TSO.Time.EumUnitDescription))
    timestepsec = dm.TSO.Time.TimeStep.Value;
  elseif (strcmp('minute',dm.TSO.Time.EumUnitDescription))
    timestepsec = dm.TSO.Time.TimeStep.Value * 60;
  elseif (strcmp('hour',dm.TSO.Time.EumUnitDescription))
    timestepsec = dm.TSO.Time.TimeStep.Value * 3600;
  elseif (strcmp('day',dm.TSO.Time.EumUnitDescription))
    timestepsec = dm.TSO.Time.TimeStep.Value * (3600*24);
  else
    timestepsec = ...
      dm.TSO.Time.TimeStep.ConvertStructToSecs(...
        dm.TSO.Time.TimeStep.Year,...
        dm.TSO.Time.TimeStep.Month,...
        dm.TSO.Time.TimeStep.Day,...
        dm.TSO.Time.TimeStep.Hour,...
        dm.TSO.Time.TimeStep.Minute,...
        dm.TSO.Time.TimeStep.Second,...
        dm.TSO.Time.TimeStep.Millisecond);
  end
else
  timestepsec = -1;
end

%% Get all properties
if (nargin == 1)
  
  % File properties
  val.FileName   = dm.TSO.Connection.FilePath;
  val.FileTitle  = dm.TSO.Connection.FileTitle;
  val.Dimensions = 1;
  
  % Item properties
  val.NumItems = dm.TSO.Count;
  for i=1:dm.TSO.Count
    val.ItemNames{i,1}       = dm.TSO.Item(i).Name;
    val.Items{i,1}           = dm.TSO.Item(i).Name;
    val.Items{i,2}           = dm.TSO.Item(i).EumTypeDescription;
    val.Items{i,3}           = dm.TSO.Item(i).EumUnitDescription;
    val.Items{i,4}           = 1; % Always node based
    val.Items{i,5}           = dm.TSO.Item(i).EumType;
    val.Items{i,6}           = dm.TSO.Item(i).EumUnit;
    val.ItemValueTypes{i}    = dm.TSO.Item(i).ValueType;
    val.ItemDataTypes{i}     = dm.TSO.Item(i).DataType;
    val.ItemCoordinates(i,1) = dm.TSO.Item(i).Origin.x;
    val.ItemCoordinates(i,2) = dm.TSO.Item(i).Origin.y;
    val.ItemCoordinates(i,3) = dm.TSO.Item(i).Origin.z;
  end

  % Time properties
  val.TimeAxisType = dm.TSO.Time.TimeType;
  if (dm.TSO.Time.IsCalendar)
    val.StartDate = datetime(1,:);
    val.EndDate = datetime(end,:);
  else
    val.StartDate = datetime(1);
    val.EndDate = datetime(end);
  end
  if (timestepsec >= 0)
    val.TimestepSec = timestepsec;
    partSec = mod(timestepsec,60);
    val.Timestep = [
        dm.TSO.Time.TimeStep.Year,...
        dm.TSO.Time.TimeStep.Month,...
        dm.TSO.Time.TimeStep.Day,...
        dm.TSO.Time.TimeStep.Hour,...
        dm.TSO.Time.TimeStep.Minute,...
        partSec
       ]; 
  end
  val.NumTimeSteps = dm.TSO.Time.NrTimeSteps;

  % File properties
  val.Projection  = '';
  val.DeleteValue = dm.TSO.DeleteValue;

  % Object properties
  val.TSObject = dm.TSO;

  if nargout==0
    disp(val)
    clear val
  end

%% Get one property from file
else

  switch lower(propName)
      
    % File properties
    case 'filename'
      val = dm.TSO.Connection.FilePath;
    case 'filetitle'
      val = dm.TSO.Connection.FileTitle;
    case 'dimensions'
      val = 1;

    % Item properties
    case 'numitems'
      val = dm.TSO.Count;
    case 'itemnames'
      for i=1:dm.TSO.Count
        val{i,1} = dm.TSO.Item(i).Name;
      end
    case 'items'
      for i=1:dm.TSO.Count
        val{i,1} = dm.TSO.Item(i).Name;
        val{i,2} = dm.TSO.Item(i).EumTypeDescription;
        val{i,3} = dm.TSO.Item(i).EumUnitDescription;
        val{i,4} = 1; % Always node based
        val{i,5} = dm.TSO.Item(i).EumType;
        val{i,6} = dm.TSO.Item(i).EumUnit;
      end
    case 'itemvaluetypes'
      for i=1:dm.TSO.Count
        val{i}    = dm.TSO.Item(i).ValueType;
      end
    case 'itemdatatypes'
      for i=1:dm.TSO.Count
        val{i}    = dm.TSO.Item(i).DataType;
      end
    case 'itemcoordinates'
      for i=1:dm.TSO.Count
        val(i,1) = dm.TSO.Item(i).Origin.x;
        val(i,2) = dm.TSO.Item(i).Origin.y;
        val(i,3) = dm.TSO.Item(i).Origin.z;
      end

    % Time properties
    case 'timeaxistype'
      val = dm.TSO.Time.TimeType;
    case 'startdate'
      if (dm.TSO.Time.IsCalendar)
        val = datetime(1,:);
      else
        val = datetime(1);
      end
    case 'enddate'
      if (dm.TSO.Time.IsCalendar)
        val = datetime(end,:);
      else
        val = datetime(end);
      end
    case 'timestepsec'
      val = timestepsec;
    case 'timestep'
      if (timestepsec >= 0)
        partSec = mod(timestepsec,60);
        val = [
            dm.TSO.Time.TimeStep.Year,...
            dm.TSO.Time.TimeStep.Month,...
            dm.TSO.Time.TimeStep.Day,...
            dm.TSO.Time.TimeStep.Hour,...
            dm.TSO.Time.TimeStep.Minute,...
            partSec
           ]; 
      else
        val = -1;
      end
    case 'numtimesteps'
      val = dm.TSO.Time.NrTimeSteps;

    % File properties
    case 'projection'
      val = '';
    case 'deletevalue'
      val = dm.TSO.DeleteValue;

    % Object properties
    case 'tsobject'
      val = dm.TSO;

    otherwise
      error([propName,' Is not a valid dfsTSO property'])
  end

end