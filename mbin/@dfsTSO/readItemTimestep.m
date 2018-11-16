function data = readItemTimestep(dm, itemnu, v)
%DFSTSO/READITEMTIMESTEP Read item data for timesteps.
%
%   Read item data for specified timesteps.
%
%   Usage:
%       data = readItemTimestep(dfs,i)    Read all timesteps of item
%       data = readItemTimestep(dfs,i,v)  Read only timesteps in v of item
%
%   input:
%      dfs        : dfs object
%      i          : Item number to read
%                   item numbers start from 1
%      v          : Vector holding index numbers to timesteps 
%                   timestep indeces start from 0
%
%   output:
%       data      : A vector containing data values for item
%
%   examples:
%       readItemTimestep(dfs,2)          : read data for all timesteps for item 2
%       readItemTimestep(dfs,2,5)        : read data for timestep 5 for item 2
%       readItemTimestep(dfs,2,5:10)     : read data for timestep 5 to 10
%       readItemTimestep(dfs,2,[5,7,10]) : read data for timestep 5, 7 and 10
%
%   note:
%       This function just wraps subscripted referencing to the data, i.e.,
%       calling 
%           data = readItemTimestep(dfs,2,5) 
%       is the same as using subcript indexing on the dfs object (see help
%       on DFSTSO/SUBSREF)
%           data = dfs(2,5)
%
%       See also DFSTSO/SUBSREF

% This function is made in order to make interface with dfs0 and the
% remaining dfs types equal (DFSManager has a readItemTimestep as the
% basic reading method)

if (nargin==2)
  data = readItem(dm,itemnu);
else
  data = readItem(dm,itemnu,v);
end

