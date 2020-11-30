function read_dfs0()
% A script loading a dfs0 file and plotting the time series, using the
% Dfs0Util for reading the dfs0 data efficiently. Without the use of the
% Dfs0Util, performance is very bad.

% %For MIKE software release 2019 or 2020, the following is required to find the MIKE installation files
% dmi = NET.addAssembly('DHI.Mike.Install');
% if (~isempty(dmi)) 
%   DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
% end

NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;

infile = 'data/data_ndr_roese.dfs0';

if (~exist(infile,'file'))
  [filename,filepath] = uigetfile('*.dfs0','Select the .dfs0');
  infile = [filepath,filename];
end

dfs0File  = DfsFileFactory.DfsGenericOpen(infile);

%% Read times and data for all items
% Use the Dfs0Util for bulk-reading all data and timesteps
dd = double(Dfs0Util.ReadDfs0DataDouble(dfs0File));
t = dd(:,1);
data = dd(:,2:end);

%% Read some item information
items = {};
for i = 0:dfs0File.ItemInfo.Count-1
   item = dfs0File.ItemInfo.Item(i);
   items{i+1,1} = char(item.Name);
   items{i+1,2} = char(item.Quantity.Unit);
   items{i+1,3} = char(item.Quantity.UnitAbbreviation); 
end

%% Plot the first 4 items of the file in each subplot
for i=1:4
  subplot(2,2,i);
  plot(t,data(:,i));
  title(items{i,1});
  axis tight
end
shg;

dfs0File.Close();


