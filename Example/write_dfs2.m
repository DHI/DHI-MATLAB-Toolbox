% Example of how to modify data in an existing dfs2 file.

% For MIKE software release 2019 or newer, the following is required to find the MIKE installation files
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi)) 
  DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

% Modify and write changes to dfs2 file
filename = 'test_written.dfs2';

% Copy to a new file, keeping the original intact.
copyfile('data/data_corner.dfs2', filename, 'f');

fileattrib(filename, '+w', 'o g'); %% change the attribute in case the source file is readonly
% Load existing dfs2 file for editing
dfs2 = DfsFileFactory.Dfs2FileOpenEdit(filename);

nsteps    = dfs2.FileInfo.TimeAxis.NumberOfTimeSteps;
deleteval = double(dfs2.FileInfo.DeleteValueFloat);

for i=0:nsteps-1

  % Read data for timestep
  itemData = dfs2.ReadItemTimeStep(1,i);
  data = double(itemData.Data);
  % Find all values not being delete value
  I = find(data ~= deleteval);
  % modify data - add 1.5
  data(I) = data(I)+1.5;
  % Write data back for timestep
  dfs2.WriteItemTimeStep(1,i,itemData.Time,NET.convertArray(single(data(:))));

end

dfs2.Close();

fprintf('\nFile created: ''%s''\n',filename);
