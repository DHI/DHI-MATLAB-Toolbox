%function create_dfs0()

% Example showing how to create a dfs0 file using the DFS library. The data
% put into the file are some arbitrary sin functions of time.

% %For MIKE software release 2019 or 2020, the following is required to find the MIKE installation files
% dmi = NET.addAssembly('DHI.Mike.Install');
% if (~isempty(dmi)) 
%   DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
% end

NETaddAssembly('DHI.Generic.MikeZero.EUM.dll');
NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
H = NETaddDfsUtil();
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.*;


% Flag specifying whether dfs0 file stores floats or doubles.
% MIKE Zero assumes floats, MIKE URBAN handles both.
useDouble = false;

% Flag specifying wether to use the MatlabDfsUtil for writing, or whehter
% to use the raw DFS API routines. The latter is VERY slow, but required in
% case the MatlabDfsUtil.XXXX.dll is not available.
useUtil = ~isempty(H);

if (useDouble)
  dfsdataType = DfsSimpleType.Double;
else
  dfsdataType = DfsSimpleType.Float;
end

% Create a new dfs1 file
filename = 'test_created.dfs0';

% Create an empty dfs1 file object
factory = DfsFactory();
builder = DfsBuilder.Create('Matlab dfs0 file','Matlab DFS',0);

builder.SetDataType(0);
proj = factory.CreateProjectionGeoOrigin('UTM-33',12,54,2.6);
builder.SetGeographicalProjection(proj);
date = System.DateTime(2002,2,25,13,45,32);
unit = eumUnit.eumUsec;
tAxis = factory.CreateTemporalNonEqCalendarAxis(unit, date);
builder.SetTemporalAxis(tAxis);

% Add three items
eumWl = eumItem.eumIWaterLevel;
eumMt = eumUnit.eumUmeter;
quantity = DHI.Generic.MikeZero.eumQuantity(eumWl, eumMt);
item1 = builder.CreateDynamicItemBuilder();
item1.Set('WaterLevel item', quantity, dfsdataType);
item1.SetValueType(DataValueType.Instantaneous);
item1.SetAxis(factory.CreateAxisEqD0());
builder.AddDynamicItem(item1.GetDynamicItemInfo());

item2 = builder.CreateDynamicItemBuilder();
item2.Set('current', DHI.Generic.MikeZero.eumQuantity(eumItem.eumICurrentSpeed,eumUnit.eumUmeterPerSec), dfsdataType);
item2.SetValueType(DataValueType.Instantaneous);
item2.SetAxis(factory.CreateAxisEqD0());
builder.AddDynamicItem(item2.GetDynamicItemInfo());

item3 = builder.CreateDynamicItemBuilder();
item3.Set('Rain', DHI.Generic.MikeZero.eumQuantity(eumItem.eumIRainfallIntensity,eumUnit.eumUmillimeterPerHour), dfsdataType);
item3.SetValueType(DataValueType.Instantaneous);
item3.SetAxis(factory.CreateAxisEqD0());
builder.AddDynamicItem(item3.GetDynamicItemInfo());

% Create the file - make it ready for data
builder.CreateFile(filename);
dfs = builder.GetFile();

% Write 10.000 time steps to the file, preallocate vector
% for time and a matrix for data for each item.
numTimes = 10000;
times = zeros(numTimes,1);
data  = zeros(numTimes,3);

% Create time vector - constant time step of 60 seconds here
times(:) = 60*(0:numTimes-1)';

% Create data vector, for each item
data(:,1) = 10 + sin(2*pi*times./(3600*24)) + times./60000;
data(:,2) = abs(sin(2*pi*times./(3600*24)));
data(:,3) = 30*(sin(2*pi*times./(3600*24*3))-0.2).^3;
% Remove negative values from rain item
data(data(:,3) < 0,3) = 0;

% Put some date in the file
tic
if useUtil
  % Write to file using the MatlabDfsUtil
  MatlabDfsUtil.DfsUtil.WriteDfs0DataDouble(dfs, NET.convertArray(times), NET.convertArray(data, 'System.Double', size(data,1), size(data,2)))
else
  % Write to file using the raw .NET API (very slow)
  for i=1:numTimes
    if (useDouble)
      dfs.WriteItemTimeStepNext(times(i), NET.convertArray(data(i,1))); 
      dfs.WriteItemTimeStepNext(times(i), NET.convertArray(data(i,2))); 
      dfs.WriteItemTimeStepNext(times(i), NET.convertArray(data(i,3))); 
    else
      dfs.WriteItemTimeStepNext(times(i), NET.convertArray(single(data(i,1)))); 
      dfs.WriteItemTimeStepNext(times(i), NET.convertArray(single(data(i,2)))); 
      dfs.WriteItemTimeStepNext(times(i), NET.convertArray(single(data(i,3)))); 
    end
    if (mod(i,100) == 0)
      fprintf('i = %i of %i\n',i,numTimes);
    end
  end
end
toc

dfs.Close();

fprintf('\nFile created: ''%s''\n',filename);
