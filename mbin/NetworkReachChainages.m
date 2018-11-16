function chainages = NetworkReachChainages(reach, dataItemIndex)
%NetworkReachChainages Extract chainages for reach and data item
%
%   Extract chainage values, either for entire reach, or for all 
%   data points of a data item in the reach.
%
%   Usage:
%       NetworkReachChainages(res1dReach) 
%       NetworkReachChainages(res1dReach, dataItemIndex) 
%
%   Inputs:
%       res1dReach     : res1dReach object, from a ResultData object
%       dataItemNumber : Index of data item to get chainages from (zero 
%                        based). If left out, chainages from the entire
%                        reach is returned.
%
%   The chainages can be used in a profile plot.

% Copyright, DHI, 2014-01-20. Author: JGR

if (~isa(reach,'DHI.Mike1D.ResultDataAccess.IRes1DReach'))
  disp 'ERROR: First argument is not an IRes1DReach'
  return
end

if (nargin == 1)
  chainages = zeros(reach.GridPoints.Count,1);
  for i=1:reach.GridPoints.Count
    chainages(i) = reach.GridPoints.Item(i-1).Chainage;
  end
else
  chainages = double(reach.GetChainages(dataItemIndex));
end
