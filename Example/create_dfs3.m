% Example on how to create a dfs3 file. The data put into the file are some
% arbitrary sine/cosine function of time and space.

% For MIKE software release 2019 or newer, the following is required to find the MIKE installation files
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi)) 
  DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end

NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs123.*;
import DHI.Generic.MikeZero.*

% Creates a new dfs3 file.
filename = 'test_created.dfs3';

% Create an empty dfs file object
factory = DfsFactory();
builder = Dfs3Builder.Create('Matlab dfs3 file','Matlab DFS',0);
builder.SetDataType(0);

% Create a temporal definition
builder.SetTemporalAxis(factory.CreateTemporalEqCalendarAxis(eumUnit.eumUsec,System.DateTime(2002,2,25,13,45,32),0,3600));

% Create a spatial defition
builder.SetSpatialAxis(factory.CreateAxisEqD3(eumUnit.eumUmeter,11,0,100,6,0,200,6,-50,10));
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-33',12,54,2.6));

% Add two items
builder.AddDynamicItem('Water Salinity',eumQuantity(eumItem.eumISalinity,eumUnit.eumUPSU),DfsSimpleType.Float,DataValueType.Instantaneous);
builder.AddDynamicItem('Current',eumQuantity(eumItem.eumICurrentSpeed,eumUnit.eumUmeterPerSec),DfsSimpleType.Float,DataValueType.Instantaneous);

% Create the file ready for data
builder.CreateFile(filename);
dfs = builder.GetFile();

% read coordinates and create a 2D coordinate set using meshgrid
x = linspace(0,1000,11);
y = linspace(0,1000,6);
z = linspace(-50,0,6);
[X,Y,Z] = meshgrid(x,y,z);
% Put some data in the file
for i=0:24, 
  data1 = 12*(1+(Z/50)).*(cos(2*X*(pi/1000)-i*2*pi/25)     .*sin(Y*(pi/1000))+1) + 32*(-Z/50); 
  data2 =    (1+(Z/50)).*(cos(X*(2*pi/1000)-i*2*pi/25+pi/2).*sin(Y*(pi/1000))); 
  % Transpose data in the x-y plane.
  data1 = permute(data1,[2,1,3]);
  data2 = permute(data2,[2,1,3]);
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data1(:)))); 
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data2(:)))); 
end

dfs.Close();

fprintf('\nFile created: ''%s''\n',filename);
