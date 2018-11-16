function NetworkResult(filename1, filename2)
%NetworkResult Show Network result files
%
%   Load and present data from one or two network result files.
%
%   Network results are files from MIKE 1D, MIKE 11 or MOUSE, usually
%   having one of the extensions
%     .res11, .res1d, .prf, .trf
%
%   There are 3 navigation modes, which can be updated by pressing 'g', 'p'
%   or 'c'. The 3 modes have the following behavior:
%      g: Clicking on the plot will plot grid point time series for the 
%         grid point closest to the click. See NetworkPlotGridPoint for
%         details.
%      p: Clicking on the plot will plot a profile plots for the reach
%         closest to the click. See NetworkPlotProfile for details, and
%         also on how to navigate in that plot.
%      c: Each click on the plot will plot a time series of the grid points
%         in the same plot: The first click will plot a time series plot
%         for the first grid point. Clicking on another grid point will add
%         the time series for that grid point to the plot and also plot the
%         differences. This can be continued as many times as requred. To
%         reset, press c again.
%
% Compatibility: 
%    1) Requires that either MIKE Zero (with MIKE 11) or MIKE URBAN is
%       installed, i.e. MIKE SDK is not sufficient.
%    2) Reading of MOUSE results are only supported by Release 2014 and
%       later. 
%    3) In Release 2011 and 2012, a 32 bit version of MATLAB must be used.

% Copyright, DHI, 2014-01-20. Author: JGR

NET.addAssembly('DHI.Mike1D.ResultDataAccess');
import DHI.Mike1D.ResultDataAccess.*

try

  data.clickAction = 'g';
  
  if (nargin == 0)
    % No arguments included, pop up file selector
    [fn1, pathname1] = uigetfile({'*.res1d';'*.res11';'*.*'},'MIKE 1D result file');
    [fn2, pathname2] = uigetfile({'*.res11';'*.res1d';'*.*'},'MIKE 11 result file');
    filename1 = [pathname1 fn1];
    filename2 = [pathname2 fn2];
  elseif (nargin == 1)
    filename2 = 0;
    fn1 = filename1;
    fn2 = '';
  else
    fn1 = filename1;
    fn2 = filename2;
  end
  
  rda1 = DHI.Mike1D.ResultDataAccess.ResultData();
  rda1.Connection = DHI.Mike1D.Generic.Connection.Create(filename1);
  rda1.Load();

  if (ischar(filename2))
    rda2 = DHI.Mike1D.ResultDataAccess.ResultData();
    rda2.Connection = DHI.Mike1D.Generic.Connection.Create(filename2);
    rda2.Load();
  else
    rda2 = {};  
  end
  
  % add filter
  
  CChainages = [];
  XX = [];
  YY = [];
  ZZ = [];
  BB = [];
  GP = [];
  
  f = figure;
  hold('on');
  grid on;
  %axis('off');
  %axis('equal');
  xmin = 1e10;
  xmax = -1e10;
  ymin = 1e10;
  ymax = -1e10;
  zmin = 1e10;
  zmax = -1e10;
  
  tic;
  h = zeros(rda1.Reaches.Count);
  for i = 1:rda1.Reaches.Count
    branch = rda1.Reaches.Item(i-1);

    % Extract digipoint coordinates
    digiPoints = branch.DigiPoints;
    digiData = zeros(digiPoints.Count,4);
    for j=1:digiPoints.Count
      digiPoint = digiPoints.Item(j-1);
      digiData(j,1) = digiPoint.M;
      digiData(j,2) = digiPoint.X;
      digiData(j,3) = digiPoint.Y;
    end
    
    % Extract grid point coordinates
    gridPoints = branch.GridPoints;
    gridPointsCount = gridPoints.Count;
    X = zeros(gridPointsCount,1);
    Y = zeros(gridPointsCount,1);
    Z = zeros(gridPointsCount,1);
    Chainages = zeros(gridPointsCount,1);

    for j=1:gridPointsCount
      gridPoint = gridPoints.Item(j-1);
      Chainages(j) = gridPoint.Chainage;
      x = gridPoint.X;
      y = gridPoint.Y;
      z = gridPoint.Z;
      X(j) = x;
      Y(j) = y;
      Z(j) = z;
    end % for j=1:branch.DigiPoints.Count

    % interpolate Z in digipoints from XYZ in gridpoints
    %digiData(:,4) = interp1(hPointData(:,1),hPointData(:,4),digiData(:,1));

    % Plot digipoint coordinates
    h = plot(digiData(:,2), digiData(:,3),'r-');

    % Plot grid points
    xv = zeros(gridPointsCount,1);
    yv = zeros(gridPointsCount,1);
    for j=1:gridPointsCount
      x = X(j);
      y = Y(j);
      z = Z(j);
      if (gridPointsCount > 1 && j == 1)
        % Move it a little bit in
        x = 0.9*x + 0.1*X(j+1);
        y = 0.9*y + 0.1*Y(j+1);
        X(j) = x;
        Y(j) = y;
      end
      if (gridPointsCount > 1 && j == gridPointsCount)
        % Move it a little bit in
        x = 0.9*x + 0.1*X(j-1);
        y = 0.9*y + 0.1*Y(j-1);
        X(j) = x;
        Y(j) = y;
      end
      
      xv(j) = x;
      yv(j) = y;
    end % for j=1:branch.DigiPoints.Count
    h = plot(xv(1:2:end), yv(1:2:end), 'bo');
    h = plot(xv(2:2:end), yv(2:2:end), 'bx');

    % Update extent to include this branch 
    xmin = min([min(digiData(:,2)), xmin]);
    xmax = max([max(digiData(:,2)), xmax]);
    ymin = min([min(digiData(:,3)), ymin]);
    ymax = max([max(digiData(:,3)), ymax]);
    zmin = min([min(digiData(:,4)), zmin]);
    zmax = max([max(digiData(:,4)), zmax]);
    
    % Store data for this reach
    CChainages = [CChainages;Chainages];
    XX = [XX;X];
    YY = [YY;Y];
    ZZ = [ZZ;Z];
    BB = [BB;double(i-1)*ones(length(X),1)];  % zero based
    GP = [GP;(1:length(X))'-1];         % zero based
    
  end %  for i=1:rda1.Reaches.Count
  fprintf('Reading network data done (%4.2f)\n',toc)
  
  % Total extent is current extent plus a little buffer zone
  xmin = xmin - 0.02*(xmax-xmin);
  xmax = xmax + 0.02*(xmax-xmin);
  ymin = ymin - 0.02*(ymax-ymin);
  ymax = ymax + 0.02*(ymax-ymin);
  zmin = zmin - 0.02*(zmax-zmin);
  zmax = zmax + 0.02*(zmax-zmin);
  
  % Set limits of plot
  if (xmin ~= xmax)
    xlim([xmin,xmax]);
  end
  if (ymin ~= ymax)
      ylim([ymin,ymax]);
  end
  
  % Update name and title of plot
  if (~ischar(fn2))
    set(f,'Name',fn1);
  else
    set(f,'Name',[fn1 ' - ' fn2]);
  end
  titleinfo = 'g';
  title(sprintf('Press: p = profile, g = gridpoint time series, c = compare gridpoints \n Currently using %s',titleinfo));
  
  % Store recorded data
  data.rda1 = rda1;
  data.rda2 = rda2;

  data.Chainages = CChainages;
  data.X = XX;
  data.Y = YY;
  data.Z = ZZ;
  data.ReachNum = BB;
  data.GridPointNum = GP;
  
  guidata(f,data);
  set(f,'KeyPressFcn',{@NetworkResultAction,f});
  set(f,'WindowButtonDownFcn',{@NetworkResultAction,f});
  
catch
  rethrow(lasterror)  
end;

%% GUI helper functions
function NetworkResultAction(src,eventdata,F)
% Function to react on mouse and keyboard events from main plot

if (src ~= F)
  return
end

data  = guidata(F);

%% Key input - change mode
if (numel(eventdata) > 0)

  s = eventdata.Character;
  k = eventdata.Key;
  
  % exit on certain keys
  if (strcmp(k,'alt') || strcmp(k,'control'))
    return
  end
  
  switch (lower(k))
    
    case 'c'
      data.clickAction = 'c';
      data.figno = -1;
      data.ref1 = [];
      data.ref2 = [];
      data.count = 0;
    case 'g'
      data.clickAction = 'g';
    case 'p'
      data.clickAction = 'p';
  end
  

%% Mouse input
else
  
  % Get mouse position
  pt = get(gca,'currentpoint');
  % Mouse coordinages
  x  = pt(1,1);
  y  = pt(1,2);
  X = data.X;
  Y = data.Y;

  % Find closest gridpoint and its reach number
  [dist,nn] = min((X-x).^2+(Y-y).^2);
  reachNum = data.ReachNum(nn);
  gridPointNum = data.GridPointNum(nn);
  
  switch (lower(data.clickAction))
    case 'c'
      data.count = data.count+1;
      [ref1,ref2,figno] = NetworkPlotGridPointDifferences(data.figno, reachNum, gridPointNum, data.rda1, data.rda2, data.ref1, data.ref2, data.count);
      if data.count == 1
        data.figno = figno;
        data.ref1 = ref1;
        data.ref2 = ref2;
      end
    case 'g'
      NetworkPlotGridPoint(reachNum, gridPointNum, data.rda1, data.rda2)  
    case 'p'
      NetworkPlotProfile(reachNum, data.rda1, data.rda2)
  end
  

  
end

switch (data.clickAction)
  case 'c'
    titleinfo = sprintf('c - %i',data.count);
  case 'g'
    titleinfo = 'g';
  case 'p'
    titleinfo = 'p';
end

f = get(src,'children');
title(f,sprintf('Press: p = profile, g = gridpoint time series, c = compare gridpoints \n Currently using %s',titleinfo));

guidata(F,data);


function [ref1, ref2, figno] = NetworkPlotGridPointDifferences(figno, reachIndex, gridpointIndex, rd1, rd2, ref1, ref2, count)  
% Plot data for different grid points in the same plot, in order to compare
% grid point values at different chainages.
%
% The branchNumber and gridPointNumber are zero based

val2 = [];
colors = 'bgrcmyk';
if (count > 7)
  count = 7;
end
marker = '+';
if (count == 1)
  marker = 'o';
end

if (count == 1)
  figno = figure;
else
  figure(figno);
end

reach1 = rd1.Reaches.Item(reachIndex);

itemNumbers = [];
pointNumbers = [];

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

for i = 1:length(itemNumbers);
  itemNumber = itemNumbers(i);
  pointNumber = pointNumbers(i);   % index into dataItem of gridpointNumber
  dataItem1 = reach1.DataItems.Item(itemNumber);

  val1 = double(dataItem1.CreateTimeSeriesData(pointNumber));
  subplot(2,length(itemNumbers),i);
  hold on
  if (isempty(rd2))
    plot(1:length(val1),val1,['-' marker colors(count)]);
  else
    reach2 = rd2.Reaches.Item(reachIndex);
    dataItem2 = reach2.DataItems.Item(itemNumber);
    val2 = double(dataItem2.CreateTimeSeriesData(pointNumber));
    plot(1:length(val1),val1,['-' marker colors(count)],1:length(val2),val2,['-' colors(count)]);
  end
  if (count == 1)
    title(sprintf('%s, chainage %f',char(reach1.Name),reach1.GridPoints.Item(dataItem1.IndexList.GetValue(pointNumber)).Chainage));
    ylabel([char(dataItem1.Quantity.Description), ' (', char(dataItem1.Quantity.EumQuantity.UnitAbbreviation),')']);
    grid('on');
  end
  hold off

  subplot(2,length(itemNumbers),length(itemNumbers)+i);
  if (isempty(ref1))
    ref1 = val1;
    ref2 = val2;
  else
    if (count > 2)
      hold on;
    end
    if (isempty(rd2))
      plot(1:length(val1),val1-ref1,['-' marker colors(count)]);
    else
      plot(1:length(val1),val1-ref1,['-' marker colors(count)]',1:length(val2),val2-ref2,['-' colors(count)]);
    end
    if (count == 2)
      ylabel('difference');
      xlabel('timestep');
      grid('on');
    end
    if (count > 2)
      hold off;
    end
    if (count >=2)
      title(sprintf('selected: %s, chainage %f',char(reach1.Name),reach1.GridPoints.Item(dataItem1.IndexList.GetValue(pointNumber)).Chainage));
    end
  end

end
hold off;

