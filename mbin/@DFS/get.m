function val = get(dm, propName)
%DFS/GET Get dfsTSO properties.
%
%   Get properties from the specified object and return the value
%
%   Usage:
%       get(dfs)            :  prints all get'able properties
%       a = get(dfs)        :  retrieves all get'able properties
%       a = get(dfs,'prop') :  retrieves property named 'prop'

% Version 1, 2014-02-02, JGR

if (~isa(dm.dfsFile, 'DHI.Generic.MikeZero.DFS.IDfsFile'))
  error('DFS:Empty',[inputname(1),' is an empty DFS object']);
end

%% Get time information from file.
timeAxis = dm.dfsFile.FileInfo.TimeAxis;
timeAxisType = int32(timeAxis.TimeAxisType);
timespan = DHI.Generic.MikeZero.DFS.DfsExtensions.TimeSpanInSeconds(timeAxis);
if (timeAxisType == dm.TIME_EQ_CAL || timeAxisType == dm.TIME_NONEQ_CAL)
  dts = timeAxis.StartDateTime;
  dte = dts.AddSeconds(timespan);
  datetime = [ [dts.Year, dts.Month, dts.Day, dts.Hour, dts.Minute, dts.Second];
               [dte.Year, dte.Month, dte.Day, dte.Hour, dte.Minute, dte.Second]];
else
  datetime = [timeAxis.StartTimeOffset ; timeAxis.StartTimeOffset+timespan];
end

% Get timestep information from file.
if (timeAxisType == dm.TIME_EQ_CAL || timeAxisType == dm.TIME_EQ_TIME)
  timestepsec = DHI.Generic.MikeZero.DFS.DfsExtensions.TimeStepInSeconds(timeAxis);
end


%% Get all properties
if (nargin == 1)
  
  % File properties
  val.FileName   = char(dm.dfsFile.FileName);
  val.FileTitle  = char(dm.dfsFile.FileInfo.FileTitle);
  %val.Dimensions = 1;
  
  % Item properties
  val.NumItems = dm.dfsFile.ItemInfo.Count;
  
  for i=1:val.NumItems
    item = dm.dfsFile.ItemInfo.Item(i-1);
    val.ItemNames{i,1}       = char(item.Name);
    val.Items{i,1}           = char(item.Name);
    val.Items{i,2}           = char(item.Quantity.ItemDescription);
    val.Items{i,3}           = char(item.Quantity.UnitAbbreviation);
    val.Items{i,4}           = 1; % Always node based
    val.Items{i,5}           = item.Quantity.Item;
    val.Items{i,6}           = item.Quantity.Unit;
    val.ItemValueTypes{i}    = item.ValueType;
    val.ItemDataTypes{i}     = item.DataType;
    val.ItemCoordinates(i,1) = item.ReferenceCoordinateX;
    val.ItemCoordinates(i,2) = item.ReferenceCoordinateY;
    val.ItemCoordinates(i,3) = item.ReferenceCoordinateZ;
  end

  % Time properties
  val.TimeAxisType = char(dm.dfsFile.FileInfo.TimeAxis.TimeAxisType);
  if (timeAxisType == dm.TIME_EQ_CAL || timeAxisType == dm.TIME_NONEQ_CAL)
    val.StartDate = datetime(1,:);
    val.EndDate = datetime(end,:);
  else
    val.StartDate = datetime(1);
    val.EndDate = datetime(end);
  end
  if (timestepsec >= 0)
    val.TimestepSec = timestepsec;
  end
  val.NumTimeSteps = dm.dfsFile.FileInfo.TimeAxis.NumberOfTimeSteps;

  % File properties
  val.Projection  = dm.dfsFile.FileInfo.Projection.WKTString;
  val.dfsFile = dm.dfsFile;
  
  if nargout==0
    disp(val)
    clear val
  end

%% Get one property from file
else

  switch lower(propName)
      
    % File properties
    case 'filename'
      val = char(dm.dfsFile.FileName);
    case 'filetitle'
      val = char(dm.dfsFile.FileInfo.FileTitle);
    %case 'dimensions'
    %  val = 1;

    % Item properties
    case 'numitems'
      val = dm.dfsFile.ItemInfo.Count;
    case 'itemnames'
      for i=1:dm.dfsFile.ItemInfo.Count
        item = dm.dfsFile.ItemInfo.Item(i-1);
        val{i,1} = char(item.Name);
      end
    case 'items'
      for i=1:dm.dfsFile.ItemInfo.Count
        item = dm.dfsFile.ItemInfo.Item(i-1);
        val{i,1} = char(item.Name);
        val{i,2} = char(item.Quantity.ItemDescription);
        val{i,3} = char(item.Quantity.UnitAbbreviation);
        val{i,4} = 1; % Always node based
        val{i,5} = item.Quantity.Item;
        val{i,6} = item.Quantity.Unit;
      end
    case 'itemvaluetypes'
      for i=1:dm.dfsFile.ItemInfo.Count
        item = dm.dfsFile.ItemInfo.Item(i-1);
        val{i}    = item.ValueType;
      end
    case 'itemdatatypes'
      for i=1:dm.dfsFile.ItemInfo.Count
        item = dm.dfsFile.ItemInfo.Item(i-1);
        val{i}    = item.DataType;
      end
    case 'itemcoordinates'
      for i=1:dm.dfsFile.ItemInfo.Count
        item = dm.dfsFile.ItemInfo.Item(i-1);
        val(i,1) = item.ReferenceCoordinateX;
        val(i,2) = item.ReferenceCoordinateY;
        val(i,3) = item.ReferenceCoordinateZ;
      end

    % Time properties
    case 'timeaxistype'
      val = char(dm.dfsFile.FileInfo.TimeAxis.TimeAxisType);
    case 'startdate'
      if (timeAxisType == dm.TIME_EQ_CAL || timeAxisType == dm.TIME_NONEQ_CAL)
        val = datetime(1,:);
      else
        val = datetime(1);
      end
    case 'enddate'
      if (timeAxisType == dm.TIME_EQ_CAL || timeAxisType == dm.TIME_NONEQ_CAL)
        val = datetime(end,:);
      else
        val = datetime(end);
      end
    case 'timestepsec'
      val = timestepsec;
    case 'numtimesteps'
      val = dm.dfsFile.FileInfo.TimeAxis.NumberOfTimeSteps;

    % File properties
    case 'projection'
      val = dm.dfsFile.FileInfo.Projection.WKTString;
    %case 'deletevalue'
    %  val = dm.TSO.DeleteValue;

    % Object properties
    case 'dfsfile'
      val = dm.dfsFile;

    otherwise
      error([propName,' Is not a valid DFS property'])
  end

end