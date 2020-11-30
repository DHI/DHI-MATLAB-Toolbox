% Example on how to create a dfs1 file with non-equidistant spatial axis
% (curvelinear). The data put into the file are some arbitrary create
% functions of time and space.

% %For MIKE software release 2019 or 2020, the following is required to find the MIKE installation files
% dmi = NET.addAssembly('DHI.Mike.Install');
% if (~isempty(dmi)) 
%   DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
% end

NETaddAssembly('DHI.Generic.MikeZero.EUM.dll');
NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
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
date = System.DateTime(2002,2,25,13,45,32);
tempAxis = factory.CreateTemporalEqCalendarAxis(eumUnit.eumUsec, date, 0,60);
%tempAxis = factory.CreateTemporalNonEqCalendarAxis(eumUnit.eumUsec, date);
builder.SetTemporalAxis(tempAxis);

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
  dfs.WriteItemTimeStepNext(2*i, NET.convertArray(single(data1(:)))); 
  dfs.WriteItemTimeStepNext(2*i, NET.convertArray(single(data2(:)))); 
end

dfs.Close();

fprintf('\nFile created: ''%s''\n',filename);
