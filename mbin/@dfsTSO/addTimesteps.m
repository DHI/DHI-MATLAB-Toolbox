function dm = addTimesteps(dm,ntimesteps)
%DFSTSO/ADDTIMESTEP Adds timesteps to end of file.
%
%   Adds ntimesteps number of timesteps to file. Time steps will be
%   added after the last timestep.
%
%   Usage:
%       addTimesteps(dfs,ntimesteps)
%
%   Inputs:
%       dfs      : DFS object
%       ntimesteps : Number of timesteps to add
%
%   Note:
%       AddTimesteps affects all items of the file since number of data
%       elements in an item is always equal to Number of timesteps, which
%       is updated by addTimesteps. New data values in each item will be
%       set with the DeleteValue.   

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

dm.TSO.Time.AddTimeSteps(ntimesteps);
