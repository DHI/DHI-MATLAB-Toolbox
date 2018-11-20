
% This file is the function version of the read_dfs0_script, that shows
% that it is much faster to do the same in a function compared to in a
% script. The only difference between the two is the top line, defining the
% function.

% For MIKE software release 2019 or newer, the following is required to find the MIKE installation files
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi)) 
  DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.DFS.dfs0.*;

infile = 'data/data_ndr_roese.dfs0';

if (~exist(infile,'file'))
  [filename,filepath] = uigetfile('*.dfs0','Select the .dfs0');
  infile = [filepath,filename];
end

dfs0File  = DfsFileFactory.DfsGenericOpen(infile);

%% Read times and data - one timestep at a time - this is VERY slow!
% Matlab does not handle .NET method calls very efficiently, so the user
% should minimize the number of method calls to .NET components.
t = zeros(dfs0File.FileInfo.TimeAxis.NumberOfTimeSteps,1);
data = zeros(dfs0File.FileInfo.TimeAxis.NumberOfTimeSteps,dfs0File.ItemInfo.Count);
tic
for it = 1:dfs0File.FileInfo.TimeAxis.NumberOfTimeSteps
  for ii = 1:dfs0File.ItemInfo.Count
    itemData = dfs0File.ReadItemTimeStep(ii,it-1);
    if (ii == 1)
        t(it) = itemData.Time;
    end
    data(it, ii) = double(itemData.Data);
  end
  if (mod(it,100) == 0)
    fprintf('it = %i of 7921\n',it);
  end
end
toc
fprintf('Did app. %f .NET calls per second\n',...
double(dfs0File.FileInfo.TimeAxis.NumberOfTimeSteps*(2*dfs0File.ItemInfo.Count+1))/toc);


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

