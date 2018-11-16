function [] = NetworkPlotGridPoint(reachIndex, gridpointIndex, rd1, rd2)  
%NetworkPlotGridPoint Plot data from grid point
%
%   Plot all data quantities of the grid point specified.
%
%   Usage 
%      NetworkPlotGridPoint(reachIndex, gridpointIndex, rda)  
%      NetworkPlotGridPoint(reachIndex, gridpointIndex, rda, rda2)  
%
%   Inputs:
%      reachIndex     : Zero based index into list of reaches
%      gridpointIndex : Zero based index into list of grid points in reach
%      rd             : Result data object
%      rd2            : Second result data object, for comparison. The rd2
%                       must have the same structure as the primare rd,
%                       otherwise this will fail.

% Copyright, DHI, 2014-01-20. Author: JGR

figure;
reach1 = rd1.Reaches.Item(reachIndex);

itemNumbers = [];
pointNumbers = [];

% Find the quantities that have values on the current grid point
for i = 1:reach1.DataItems.Count
  % Search if gridpointNumber is in DataItems indexlist
  [dummy,pointNumber] = find(double(reach1.DataItems.Item(i-1).IndexList)==gridpointIndex);
  if (numel(dummy) > 0)
    % find the itemnumbers that this gridpoint is utilizing
    itemNumbers(end+1) = i-1;
    % index into dataItem of gridpointNumber - used to find chainages
    pointNumbers(end+1) = pointNumber-1;
  end
end

hasTwo = nargin == 4 && ~isempty(rd2);

for i = 1:numel(itemNumbers);
  itemNumber = itemNumbers(i);
  pointNumber = pointNumbers(i);   % index into dataItem of gridpointNumber

  dataItem1 = reach1.DataItems.Item(itemNumber);

  % Extract time series data from data item
  val1 = double(dataItem1.CreateTimeSeriesData(pointNumber));
  if (hasTwo)
    reach2 = rd2.Reaches.Item(reachIndex);
    dataItem2 = reach2.DataItems.Item(itemNumber);
    val2 = double(dataItem2.CreateTimeSeriesData(pointNumber));
  end
  if (~hasTwo)
    subplot(length(itemNumbers),1,i);
    h = plot(1:length(val1),val1);
    title(sprintf('%s, chainage %f',char(reach1.Name),reach1.GridPoints.Item(dataItem1.IndexList.GetValue(pointNumber)).Chainage));
    ylabel([char(dataItem1.Quantity.Description), ' (', char(dataItem1.Quantity.EumQuantity.UnitAbbreviation),')']);
    xlabel('timestep');
    grid('on');
  else
    subplot(2*length(itemNumbers),1,2*(i-1)+1);
    h = plot(1:length(val1),val1,'-x',1:length(val2),val2);
    title(sprintf('%s, chainage %f',char(reach1.Name),reach1.GridPoints.Item(dataItem1.IndexList.GetValue(pointNumber)).Chainage));
    ylabel([char(dataItem1.Quantity.Description), ' (', char(dataItem1.Quantity.EumQuantity.UnitAbbreviation),')']);
    grid('on');
    subplot(2*length(itemNumbers),1,2*(i-1)+2);
    h = plot(1:length(val1),val1-val2);
    ylabel('difference');
    xlabel('timestep');
    grid('on');
  end

end

