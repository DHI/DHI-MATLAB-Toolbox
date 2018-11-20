% Example of how to modify data in an existing dfsu file.

% This example we will show how to update two timesteps of an item, adding
% some sinusoidal "noise". We will handle delete values, such that elements
% having delete value is not updated.

% For MIKE software release 2019 or newer, the following is required to find the MIKE installation files
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi)) 
  DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

% Modify and write changes to 2D dfsu file
filename = 'test_written_2D.dfsu';

% Copy to a new file, keeping the original intact.
[status, message, messageId] = copyfile('data/data_oresund_2D.dfsu', filename, 'f');

fileattrib(filename, '+w', 'o g'); %% change the attribute in case the source file is readonly
% Load existing dfsu 2D file for editing 
dfsu2 = DfsFileFactory.DfsuFileOpenEdit(filename);

% Node coordinates
xn = double(dfsu2.X);
yn = double(dfsu2.Y);
zn = double(dfsu2.Z);

% Create element table in Matlab format
tn = mzNetFromElmtArray(dfsu2.ElementTable);
% also calculate element center coordinates
[x,y,z] = mzCalcElmtCenterCoords(tn,xn,yn,zn);

deleteval = double(single(1e-35));

for i=0:1
    % Read first time step from file
    itemData = dfsu2.ReadItemTimeStep(1,i);
    data     = double(itemData.Data)';
    % Do not consider elements with delete value
    I        = find(data ~= deleteval);
    % Calculate new values, adding some noise
    data(I)  = data(I) - 0.01*cos(0.0005*x(I)).*cos(0.0003*y(I));
    % Write to memory
    dfsu2.WriteItemTimeStep(1,i,itemData.Time,NET.convertArray(single(data(:))));
end

% Save and close file
dfsu2.Close();

fprintf('\nFile created: ''%s''\n',filename);

%% The remaining part is just plotting.

% Now plot and check the difference between the original and the modified
% file.
clf, shg
%-----------------------------------------
dfsu2a = DfsFileFactory.DfsuFileOpen('data/data_oresund_2D.dfsu');

t       = mzTriangulateElmtCenters(x,y,tn);
data0   = double(dfsu2a.ReadItemTimeStep(1,0).Data);
data1   = double(dfsu2a.ReadItemTimeStep(1,1).Data);
dfsu2a.Close();

% Remove delete values from plot
data0(data0 == deleteval) = NaN;
data1(data1 == deleteval) = NaN;

subplot(2,2,1)
trimesh(t,x,y,data0)
%shading interp
title('original, first timestep')
axis tight
subplot(2,2,2)
trimesh(t,x,y,data1)
%shading interp
title('original, second timestep')
axis tight

%-----------------------------------------
dfsu2b = DfsFileFactory.DfsuFileOpen(filename);

data0   = double(dfsu2b.ReadItemTimeStep(1,0).Data);
data1   = double(dfsu2b.ReadItemTimeStep(1,1).Data);
dfsu2b.Close()

% Remove delete values from plot
data0(data0 == deleteval) = NaN;
data1(data1 == deleteval) = NaN;

subplot(2,2,3)
trimesh(t,x,y,data0)
%shading interp
title('modified, first timestep')
axis tight
subplot(2,2,4)
trimesh(t,x,y,data1)
%shading interp
title('modified, second timestep')
axis tight


