function writeItemTimestep(dm, itemno, v, data)
%DFSTSO/WRITEITEMTIMESTEP Write item data.
%
%   Write item data to object. Data will only be saved to file when
%   save(dfs) is issued.
%
%   Usage:
%       writeItemTimestep(dfs,i,data)     write all timesteps of item
%       writeItemTimestep(dfs,i,v,data)   write only timesteps in v of item
%
%   Input:
%       dfs       : dfs object
%       i         : Item number to read
%                   item numbers start from 1
%       v         : Vector holding index numbers to timesteps 
%                   timestep indeces start from 0
%       data      : Vector holding data of item
%
%   Examples:
%       See DFSTSO/READITEM for examples of inputs
%
%   Note:
%       You may use subscripted referencing, since calling 
%           writeItemTimestep(dfs,2,5,data) 
%       is the same as using subcript references on the dfs object (see
%       help on DFSTSO/SUBSREF)
%           dfs(2,5) = data
%
%       See also DFSTSO/SUBSREF, DFSTSO/READITEM

% This function is made in order to make interface with dfs0 and the
% remaining dfs types equal (DFSManager has a writeItemTimestep as the
% basic writing method)

if nargin==3
  writeItem(dm,itemno,v);
else
  writeItem(dm,itemno,v,data);
end
