% Example on how to read network results. This procedure can be used for
% network result files from MIKE 11, MOUSE and MIKE 1D. It supports reading
% files with the following extensions
%    res11 : MIKE 11 result files
%    res1d : MIKE 1D result files
%    prf   : MOUSE network HD results
%    trf   : MOUSE network AD results
%    xrf   : MOUSE network HD additional results
%    crf   : MOUSE catchment/rainfall runoff results
%
% Compatibility: 
%    1) Requires that either MIKE Zero (with MIKE 11) or MIKE URBAN is
%       installed, i.e. MIKE SDK is not sufficient.
%    2) Reading of MOUSE results are only supported by Release 2014 and
%       later. 
%    3) In Release 2011 and 2012, a 32 bit version of MATLAB must be used.
%
% The ResultData object can contain results for nodes, reaches, catchments
% and global/system data. Each of these can contain a number of DataItems.
% One dataitem contains data for one Quantity, e.g. 'Water Level'. The
% dataitem contains a vector of data for each time step in the 'TimeData'
% variable.
%
% Example:
%  - Reaches : In a HD result file a reach will usually have two
%    dataitems, storing the quantities 'Water Level' and 'Discharge'. Each
%    of the dataitems store values in a seperate set of grid points. If
%    there is 7 grid points in the reach, water level will be stored on
%    grid point 0,2,4,6 and discharge will be stored on grid point 1,3,5.
%    The DataItem has an IndexList which indicates the grid points that the
%    values belong to
%  - Nodes, Catchments and global data will have a varynig number of
%    dataitems, depending on the type of result file. Each of these
%    dataitems will only store one value per time step in the 'TimeData'
%    variable.
%
% Also take a look at the following tools:
%    NetworkResult        : Tool that loads a network result file, shows
%                           geometry in plot and support clicking on grid
%                           points/reaches to create more plots.
%    NetworkPlotGridPoint : Plot grid point values (time series plot).
%    NetworkPlotProfile   : Plot profile and adds keyboard navigation to go
%                           go forward/backward in time.

% %For MIKE software release 2019 or 2020, the following is required to find the MIKE installation files
% dmi = NET.addAssembly('DHI.Mike.Install');
% if (~isempty(dmi)) 
%   DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
% end

rdAss = NETaddAssembly('DHI.Mike1D.ResultDataAccess.dll');
import DHI.Mike1D.ResultDataAccess.*

if (rdAss.AssemblyHandle.GetName().Version.Major == 10)
  % Release 2011 does not support newer format of res1d file, use res11
  % file instead
  filename = 'data/data_vida96-3.res11';
else
  filename = 'data/data_vida96-3.res1d';
end

% Create a ResultData object and read the data file.
rd = DHI.Mike1D.ResultDataAccess.ResultData();
rd.Connection = DHI.Mike1D.Generic.Connection.Create(filename);
rd.Load();

% Select reach to extract data from:
reach = rd.Reaches.Item(0);
% Select first data item - water level (HD result files usually have two 
% data items, water level and discharge)
dataitem = reach.DataItems.Item(0);

%% Create a profile plot
% Extract chainages for reach and data item (0-based argument here)
chainages = NetworkReachChainages(reach, 0);
% Extract data for the 70th time step (zero based)
vals = double(dataitem.TimeData.GetValues(69));
% Create plot
figure(1);
plot(chainages, vals);
title(sprintf('%s, chainage %3.1f-%3.1f',char(reach.Name),min(chainages), max(chainages)));
ylabel([char(dataitem.Quantity.Description), ' (', char(dataitem.Quantity.EumQuantity.UnitAbbreviation),')']);
xlabel('Chainage');

%% Create a time series plot for a grid point and a node
figure(2)
% Extract data from grid point
vals = double(dataitem.CreateTimeSeriesData(4));
% Extract data from second node (zero based index), first data item (water
% level)
node = rd.Reaches.Item(1);
nodeDataitem = node.DataItems.Item(0);
valsNode = double(nodeDataitem.CreateTimeSeriesData(0));
% Plot data for grid point and node
plot(1:numel(vals), vals, 'b-+', 1:numel(valsNode), valsNode, 'r-x');
title(sprintf('%s, chainage %3.1f',char(reach.Name),reach.GridPoints.Item(4).Chainage));
ylabel([char(dataitem.Quantity.Description), ' (', char(dataitem.Quantity.EumQuantity.UnitAbbreviation),')']);
xlabel('timestep');
legend(sprintf('%s, chainage %3.1f',char(reach.Name),reach.GridPoints.Item(4).Chainage),sprintf('node %s',char(node.Name)));
grid('on');

