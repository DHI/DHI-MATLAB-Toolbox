% MATLAB example of reading and plotting a dfs1 file

% For MIKE software release 2019 or newer, the following is required to find the MIKE installation files
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi)) 
  DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

% Load file
dfs1 = DfsFileFactory.Dfs1FileOpen('data/data_moving_bump.dfs1');

% Extract some information of the first item.
itemname     = char(dfs1.ItemInfo.Item(0).Name);
itemunit     = char(dfs1.ItemInfo.Item(0).Quantity.UnitAbbreviation);
numtimesteps = dfs1.FileInfo.TimeAxis.NumberOfTimeSteps;

clf, shg
% Make an animation over time
for i = 0:numtimesteps-1

  % Read data for timestep
  data = single(dfs1.ReadItemTimeStep(1,i).Data)';
  
  % Plot
  plot(data);
  
  % Make plot look nice
  ylim([-0.1,1.1])
  title(sprintf('%s - %s',itemname,itemunit));
  drawnow;
  pause(0.01);
  
end

dfs1.Close();