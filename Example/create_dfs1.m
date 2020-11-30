% Example of how to create a dfs1 file. The data put into the file are some
% arbitrary sine/cosine function of time and space.

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

% Create a new dfs1 file
filename = 'test_created.dfs1';

% Create an empty dfs1 file object
factory = DfsFactory();
builder = Dfs1Builder.Create('Matlab dfs1 file','Matlab DFS',0);
builder.SetDataType(0);

% Create a temporal definition
builder.SetTemporalAxis(factory.CreateTemporalEqCalendarAxis(eumUnit.eumUsec,System.DateTime(2002,2,25,13,45,32),0,60));

% Create a spatial defition
builder.SetSpatialAxis(factory.CreateAxisEqD1(eumUnit.eumUmeter,11,0,100));
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-33',12,54,2.6));

% Add two items
builder.AddDynamicItem('Surface height',eumQuantity(eumItem.eumISurfaceElevation,eumUnit.eumUmeter),DfsSimpleType.Float,DataValueType.Instantaneous);
builder.AddDynamicItem('current',eumQuantity(eumItem.eumICurrentSpeed,eumUnit.eumUmeterPerSec),DfsSimpleType.Float,DataValueType.Instantaneous);

% Create the file - make it ready for data
builder.CreateFile(filename);
dfs = builder.GetFile();

% read coordinates
x  = linspace(0,1000,11);
% Put some date in the file
for i=0:10, 
  data1 =   -cos(x*(2*pi/1000)-i*2*pi/10); 
  data2 = 10*cos(x*(2*pi/1000)-i*2*pi/10+pi/2); 
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data1(:)))); 
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data2(:)))); 
end

dfs.Close();

fprintf('\nFile created: ''%s''\n',filename);
