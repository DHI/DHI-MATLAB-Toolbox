% Example on how to create a dfs1 file with non-equidistant spatial axis
% (curvelinear). The data put into the file are some arbitrary create
% functions of time and space.

%% For Mike software release 2017 or older, comment the following three lines:
NET.addAssembly('DHI.Mike.Install');
import DHI.Mike.Install.*;
MikeImport.Setup(MikeMajorVersion.V17, [])

NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
import DHI.Generic.MikeZero.*

% Create a dfs1 file with non equidistant spatial axis
filename = 'test_created_noneqspat.dfs1';

% Create an empty dfs1 file object
factory = DfsFactory();
builder = Dfs1Builder.Create('Matlab dfs1 file','Matlab DFS',0);
builder.SetDataType(0);

% Create a temporal definition
builder.SetTemporalAxis(factory.CreateTemporalEqCalendarAxis(eumUnit.eumUsec,System.DateTime(2002,2,25,13,45,32),0,60));

% Create a non-equidistant (curvelinear) 1D axis
x = [0;1;10;100;300;700;900;990;999;1000];
y = [700;900;990;999;1000;900;800;600;400;300];
z = [0;1;3;5;4;3;4;6;7;6];

% Create a spatial defition
builder.SetSpatialAxis(factory.CreateAxisNeqD1(eumUnit.eumUmeter,mzNetToCoordArray(x,y,z)));
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-33',12,54,2.6));

% Add two items
builder.AddDynamicItem('Surface height',eumQuantity(eumItem.eumISurfaceElevation,eumUnit.eumUmeter),DfsSimpleType.Float,DataValueType.Instantaneous);
builder.AddDynamicItem('current',eumQuantity(eumItem.eumICurrentSpeed,eumUnit.eumUmeterPerSec),DfsSimpleType.Float,DataValueType.Instantaneous);

% Create the file ready for data
builder.CreateFile(filename);
dfs = builder.GetFile();

% Put some date in the file
for i=0:10, 
  data1 =  x([i+1:end,1:i]); 
  data2 = (x/max(x)+0.1*i).^2;
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data1(:)))); 
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data2(:)))); 
end

dfs.Close();

fprintf('\nFile created: ''%s''\n',filename);
