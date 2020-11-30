% Example on how to create a dfs2 file. The data put into the file are some
% arbitrary sine/cosine function of time and space. The file matches the
% output of MIKE 21 classic h-p-q files, which are the default HD output
% from MIKE 21. 
% Note that the header is special for the MIKE 21 h-p-q files, look in the comments in the code below.

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

% create relative grid coordinates and create a 2D coordinate set using meshgrid
x = linspace(0,1000,11);
y = linspace(0,1000,6);
[X,Y] = meshgrid(x,y);

% Creates a new dfs2 file.
filename = 'test_created.dfs2';

% Create an empty dfs2 file object
factory = DfsFactory();
builder = Dfs2Builder.Create('Matlab dfs2 file','Matlab DFS',0);

% Set up the header
% DataType = 1 is special for h-p-q files. If you are not sure, set to 0. Visit the User Guide for known DataType numbers
builder.SetDataType(1);
builder.SetGeographicalProjection(factory.CreateProjectionGeoOrigin('UTM-33', 12.4387, 55.2257, 327));
builder.SetTemporalAxis(factory.CreateTemporalEqCalendarAxis(eumUnit.eumUsec,System.DateTime(1993,12,02,0,0,0),0,86400));
builder.SetSpatialAxis(factory.CreateAxisEqD2(eumUnit.eumUmeter,11,0,100,6,0,200));
builder.DeleteValueFloat = single(-1e-30);

% Add custom block 
% M21_Misc : {orientation (should match projection), drying depth, -900=has projection, land value, 0, 0, 0}
% M21_Misc Custom block is special for h-p-q files. Leave out for other dfs2 files
builder.AddCustomBlock(dfsCreateCustomBlock(factory, 'M21_Misc', [327, 0.2, -900, 10, 0, 0, 0], 'System.Single'));

% Add two items
builder.AddDynamicItem('H Water Depth m', eumQuantity.Create(eumItem.eumIWaterLevel, eumUnit.eumUmeter), DfsSimpleType.Float, DataValueType.Instantaneous);
builder.AddDynamicItem('P Flux m^3/s/m', eumQuantity.Create(eumItem.eumIFlowFlux, eumUnit.eumUm3PerSecPerM), DfsSimpleType.Float, DataValueType.Instantaneous);
builder.AddDynamicItem('Q Flux m^3/s/m', eumQuantity.Create(eumItem.eumIFlowFlux, eumUnit.eumUm3PerSecPerM), DfsSimpleType.Float, DataValueType.Instantaneous);

% Create the file ready for data
builder.CreateFile(filename);

% Add one static item, containing bathymetri data
% note that data needs to be transposed before written to dfs2 file.
data = -cos(2*X*(pi/1000).*sin(Y*(pi/1000)))'; 
builder.AddStaticItem('Static item', eumQuantity.UnDefined, NET.convertArray(single(data(:))));

% Get the file
dfs = builder.GetFile();

% Put some data in the file
for i=0:24, 
  % note that data needs to be transposed before written to dfs2 file.
  data1 = (-cos(2*X*(pi/1000)-i*2*pi/25).*sin(Y*(pi/1000)))'; 
  data2 = (10*cos(X*(2*pi/1000) + pi/2 -i*2*pi/25).*sin(Y*(pi/1000)))'; 
  data3 = (10*sin(X*(2*pi/1000) + pi/2 -i*2*pi/25).*cos(Y*(pi/1000)))'; 
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data1(:)))); 
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data2(:)))); 
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data3(:)))); 
end

dfs.Close();

fprintf('\nFile created: ''%s''\n',filename);
