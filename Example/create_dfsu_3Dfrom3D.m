% Example on how to create a dfsu 3D file. The data put into the file are
% some arbitrary function of time and space. It uses the geometry from
% another dfsu 3D file. 

NETaddAssembly('DHI.Generic.MikeZero.EUM.dll');
NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfsu.*;
import DHI.Generic.MikeZero.*

filename = 'test_created_3Dfrom3D.dfsu';

% Read 3D source input file, from where to get the geometry.
dfs_in       = DfsFileFactory.DfsuFileOpen('data/data_odense_3D.dfsu');

X            = double(dfs_in.X);
Y            = double(dfs_in.Y);
Z            = double(dfs_in.Z);
code         = double(dfs_in.Code);
Elmts        = mzNetFromElmtArray(dfs_in.ElementTable);  % Create element table in Matlab format
proj         = char(dfs_in.Projection.WKTString);
numLayers    = dfs_in.NumberOfLayers;
numtimesteps = dfs_in.NumberOfTimeSteps;
start        = dfs_in.StartDateTime;
startDate    = [start.Year, start.Month, start.Day, start.Hour, start.Minute, start.Second];

% Calculate element center coordinates. These are used in the arbitrary
% sine/cosine functions.
[Xe,Ye,Ze]   = mzCalcElmtCenterCoords(Elmts,X,Y,Z);      

% Create a new empty dfsu 3D file object
factory = DfsFactory();
builder = DfsuBuilder.Create(DfsuFileType.Dfsu3DSigma);

% Create a temporal definition matching input file
start = System.DateTime(startDate(1),startDate(2),startDate(3),startDate(4),startDate(5),startDate(6));
builder.SetTimeInfo(start, dfs_in.TimeStepInSeconds);

% Create a spatial defition based on 3D input file

builder.SetNodes(NET.convertArray(X),NET.convertArray(Y),NET.convertArray(single(Z)),NET.convertArray(int32(code)));
builder.SetElements(mzNetToElmtArray(Elmts));
builder.SetNumberOfSigmaLayers(numLayers);
builder.SetProjection(factory.CreateProjectionGeoOrigin('UTM-33', 0, 0, 0))

% Add two items
builder.AddDynamicItem('Water Salinity',eumQuantity(eumItem.eumISalinity,eumUnit.eumUPSU));
builder.AddDynamicItem('Water Temperature',eumQuantity(eumItem.eumITemperature,eumUnit.eumUdegreeCelsius));

% Create the file - make it ready for data
dfs = builder.CreateFile(filename);


%% Put some data in the file
wavelength = 0.3*max(max(Xe)-min(Xe),max(Ye)-min(Ye));
for i=0:12,
  % Read spatial item Z coordinate from source input dfsu 3D file, and
  % reuse that in the new file.
  dfs.WriteItemTimeStepNext(0, dfs_in.ReadItemTimeStep(1,i).Data);
  % Write data to other items
  data1 = -exp(Ze).*cos(Xe*(2*pi/wavelength)-i*2*pi/25)     .*sin(Ye*(2*pi/wavelength));
  data2 = 10*exp(Ze).*cos(Xe*(2*pi/wavelength)-i*2*pi/25+pi/2).*sin(Ye*(2*pi/wavelength));
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data1(:)))); 
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data2(:)))); 
end

dfs.Close();
dfs_in.Close();

fprintf('\nFile created: ''%s''\n',filename);
