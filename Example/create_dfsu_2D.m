% Example on how to create a dfsu 2D file. The data put into the file are
% some arbitrary sine/cosine functions of time and space. It uses the
% Øresund mesh file for defining the geometry

%% For Mike software release 2017 or older, comment the following three lines:
NET.addAssembly('DHI.Mike.Install');
import DHI.Mike.Install.*;
MikeImport.Setup(MikeMajorVersion.V17, [])

NET.addAssembly('DHI.Generic.MikeZero.DFS');
NET.addAssembly('DHI.Generic.MikeZero.EUM');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfsu.*;
import DHI.Generic.MikeZero.*

% Create a 2D dfsu file using domain from mesh file
filename = 'test_created_2D.dfsu';

% Load a spatial definition to use
[Elmts,Nodes,proj] = mzReadMesh('data/bathy_oresund.mesh');
X = Nodes(:,1);
Y = Nodes(:,2);
Z = Nodes(:,3);
code = Nodes(:,4);

% Create a new empty dfsu 3D file object
factory = DfsFactory();
builder = DfsuBuilder.Create(DfsuFileType.Dfsu2D);

% Create a temporal definition matching input file
startDate = [2002,2,25,13,45,32];
start = System.DateTime(startDate(1),startDate(2),startDate(3),startDate(4),startDate(5),startDate(6));
builder.SetTimeInfo(start, 3600);

% Create a spatial defition based on mesh input file
% For release 2012 and earlier the SetNodes had X and Y float arguments.
% For release 2014 and forward the SetNodes have X and Y double arguments.
% The difference is: NET.convertArray(X)  vs  NET.convertArray(single(X))
if (mzMikeVersion() > 2012)
  builder.SetNodes(NET.convertArray(X),NET.convertArray(Y),NET.convertArray(single(Z)),NET.convertArray(int32(code)));
else
  builder.SetNodes(NET.convertArray(single(X)),NET.convertArray(single(Y)),NET.convertArray(single(Z)),NET.convertArray(int32(code)));
end
builder.SetElements(mzNetToElmtArray(Elmts));
builder.SetProjection(factory.CreateProjection(proj))

% Add two items
builder.AddDynamicItem('Surface height',eumQuantity(eumItem.eumISurfaceElevation,eumUnit.eumUmeter));
builder.AddDynamicItem('Current',eumQuantity(eumItem.eumICurrentSpeed,eumUnit.eumUmeterPerSec));

% Create the file - make it ready for data
dfs = builder.CreateFile(filename);

[Xe,Ye,Ze] = mzCalcElmtCenterCoords(Elmts,X,Y,Z);

%% Put some data in the file
wavelength = 0.3*max(max(X)-min(X),max(Y)-min(Y));

for i=0:24,
  data1 = -cos(2*Xe*(pi/wavelength)-i*2*pi/25).*sin(Ye*(pi/wavelength));
  data2 = 10*cos(Xe*(2*pi/wavelength) + pi/2 -i*2*pi/25).*sin(Ye*(pi/wavelength));
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data1))); 
  dfs.WriteItemTimeStepNext(0, NET.convertArray(single(data2))); 
end

dfs.Close();

fprintf('\nFile created: ''%s''\n',filename);
