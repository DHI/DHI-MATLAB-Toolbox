% Example of how to read data from a res11 file, based on a quantity name,
% branch name and chainage value. Functionality is similiar to the
% res11read.exe.
%
% For more flexible access to res11 results, check out the read_Network.m
% example.

% For MIKE software release 2019 or newer, the following is required to find the MIKE installation files
dmi = NET.addAssembly('DHI.Mike.Install');
if (~isempty(dmi)) 
  DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
end


NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

infile = 'data\data_vida96-3.res11';

if (~exist(infile,'file'))
  [filename,filepath] = uigetfile('*.res11','Select the .res11');
  infile = [filepath,filename];
end

% Data to extract, quantity, branch name and chainages
extractPoints{1}.branchName = 'VIDAA-NED';
extractPoints{1}.quantity = 'Water Level';
extractPoints{1}.chainages = [10000, 11300];
extractPoints{2}.branchName = 'VIDAA-NED';
extractPoints{2}.quantity = 'Discharge';
extractPoints{2}.chainages = 10128;

[values, outInfos] = res11read(infile, extractPoints);

plot(values)
legend(outInfos{1}.quantity, outInfos{2}.quantity, outInfos{3}.quantity);
