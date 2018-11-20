% Example of how to create a dfs0 file using the dfsTSO class. It reads
% data from a dfs2 file, calculates an average water depth and an average
% flux, and stores it in the dfs0 file. 

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

% Create a new empty dfs0 file object
filename = 'test_created_dfsTSO.dfs0';

if exist(filename, 'file')==2
  delete(filename);
end
dfs0 = dfsTSO(filename,1);

% Load dfs2 file
dfs2 = DfsFileFactory.Dfs2FileOpen('data/data_corner.dfs2');

% Set a file title
set(dfs0,'filetitle','Average of water depth and flux');

% Set startdate and timestep interval matching dfs2 file
start = dfs2.FileInfo.TimeAxis.StartDateTime;
set(dfs0,'startdate',double([start.Year, start.Month, start.Day, start.Hour, start.Minute, start.Second]));
set(dfs0,'timestep',[0 0 0 0 0 dfs2.FileInfo.TimeAxis.TimeStep]);
% Add number of timesteps matching dfs2 file
addTimesteps(dfs0,dfs2.FileInfo.TimeAxis.NumberOfTimeSteps);

% Add Items, note the two ways of setting EUM unit and type
addItem(dfs0,'Water depth','Water Depth','m');
addItem(dfs0,'Flux average');
setItemEum(dfs0,2,'Flow Flux','m^3/s/m');

% Now we are ready to set values for items

% Loop over timesteps of dfs2 file and calculate average
for i = 0:dfs2.FileInfo.TimeAxis.NumberOfTimeSteps-1

  % Load item data (item 1 and item 2) from dfs2 file
  wd   = double(dfs2.ReadItemTimeStep(1,i).Data);
  flux = double(dfs2.ReadItemTimeStep(2,i).Data);
  
  % Remove delete values from mean (specific for this file!)
  I = find(abs(wd+1e-30)>1e-34);
  
  % Assign directly to dfs0 using subscript referencing (convert to single
  % to avoid warnings) 
  dfs0(1,i)  = single(mean(wd(I)));

  % Save in vector and assign later
  fluxav(i+1) = mean(flux(I));

end

% Assign all flux average to item 2 of dfs0 in one step (convert to single
% to avoid warnings)
dfs0(2) = single(fluxav);

% Save and close files
save(dfs0);
close(dfs0);
dfs2.Close();

fprintf('\nFile created: ''%s''\n',filename);
