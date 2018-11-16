function NetworkPlotProfile(reachIndex, rd1, rd2)
%NetworkPlotProfile Profile plot of reach
%
%   Plots a profile plot for the reach. It plots profiles for all
%   quantities in the reach in each subplot. 
%
%   Usage
%      NetworkPlotProfile(reachNum, rd)
%      NetworkPlotProfile(reachNum, rd, rd2)
% 
%   Inputs:
%      reachIndex     : Zero based index into list of reaches
%      rd             : Result data object
%      rd2            : Second result data object, for comparison. The rd2
%                       must have the same structure as the primare rd,
%                       otherwise this will fail.
%
%   Navigation:
%      Use the keyboard left/right to navigate forward/backward in time.
%      Use keyboard up/down to increase/decrease the timestep step size
%      with a factor 10. Initially the step size is 1, i.e. one keypress of
%      left/right will move the plot one time step. Pressing up once will
%      increase the step size to 10, i.e. one keypress of left/right will
%      move the plot 10 time steps. Pressing up once again will increase
%      the step size to 100.

% Copyright, DHI, 2014-01-20. Author: JGR

data.it = 0;
data.maxit = rd1.NumberOfTimeSteps;
data.step = 1;
data.clickaction = 'g';

if nargin == 2 || isempty(rd2)
  data.hasTwo = false;
  scalefig = 1;
else
  data.hasTwo = true;
  scalefig = 2;
end

f = figure;

reach = rd1.Reaches.Item(reachIndex);

sprows = reach.DataItems.Count;
spcols = scalefig;

for di = 1:reach.DataItems.Count
  dataItem = reach.DataItems.Item(di-1);
  % Read chainages from reach
  chainages = NetworkReachChainages(reach, di-1);
  % Load and store data for data item (all time step data)
  data.arrays{di} = double(dataItem.CreateDataArray);
  
  data.text{di} = reach.Name;
  
  subplot(double(sprows),double(spcols),double(di));
  if (~data.hasTwo)
    h{di} = plot(chainages,data.arrays{di}(data.it+1,:),'-+');
  else
    reach2 = rd2.Reaches.Item(reachIndex);
    dataItem2 = reach2.DataItems.Item(di-1);
    chainages2 = NetworkReachChainages(reach2, di-1);
    data.arrays2{di} = double(dataItem2.CreateDataArray);
    h{di} = plot(chainages,data.arrays{di}(data.it+1,:),'-+',chainages2,data.arrays2{di}(data.it+1,:));
  end

  ymin = min(data.arrays{di}(:));
  ymax = max(data.arrays{di}(:));
  if (data.hasTwo)
    ymin = min(ymin,min(data.arrays2{di}(:)));
    ymax = max(ymax,max(data.arrays2{di}(:)));
  end
  ylim([ymin,ymax]);
  t{di} = title(sprintf('%s - %i',char(data.text{di}),data.it));
  ylabel([char(dataItem.Quantity.Description), ' (', char(dataItem.Quantity.EumQuantity.UnitAbbreviation),')']);

  if (data.hasTwo)
    subplot(double(sprows),double(spcols),double(di+sprows));
    err = data.arrays{di}(data.it+1,:)-data.arrays2{di}(data.it+1,:);
    h{di}(end+1) = plot(chainages,err,'-+');
    t{di}(end+1) = title(sprintf('max |error| = %f',max(abs(err))));
    err = data.arrays{di}-data.arrays2{di};
    [~,maxerrit] = max(max(err'));
    xlabel(sprintf('max error at step %i',maxerrit-1));
    
  end
  
end

set(f,'KeyPressFcn',{@plotProfileAction,f,h,t});
set(f,'WindowButtonDownFcn',{@plotProfileAction,f,h,t});

guidata(f,data);

%% Helper functions
function plotProfileAction(src,eventdata,F,h,t)

if (src ~= F)
  return
end

data  = guidata(F);
it = data.it;
maxit = data.maxit;

%% Key input - change mode
if (numel(eventdata) > 0)

  s = eventdata.Character;
  k = eventdata.Key;
  
  % exit on certain keys
  if (strcmp(k,'alt') || strcmp(k,'control'))
    return
  end
  
  switch (lower(k))
    
    case 'uparrow'
      data.step = data.step*10;
      
    case 'downarrow'
      data.step = max(data.step/10,1);

    case 'leftarrow'
      if (it>data.step-1)
        it = it-data.step;
      else
        it = 0;
      end
    case 'rightarrow'
      if (it<maxit-data.step)
        it = it+data.step;
      else
        it = maxit-1;
      end
      
    case 'g'
      data.clickaction = 'g';
      
    case 'p'
      data.clickaction = 'p';
  end
  
  figure(src);
  for di = 1:length(h)
    set(h{di}(1),'YData',data.arrays{di}(it+1,:));
    set(t{di}(1),'String',sprintf('%s - %i',char(data.text{di}),it));
    if (data.hasTwo)
      set(h{di}(2),'YData',data.arrays2{di}(it+1,:));
      err = data.arrays{di}(it+1,:)-data.arrays2{di}(it+1,:);
      set(h{di}(3),'YData',err);
      set(t{di}(2),'String',sprintf('max |error| = %f',max(abs(err))));
    end
  end
  

%% Mouse input 
else
  
  % Get mouse position
  pt = get(gca,'currentpoint');
  % Mouse coordinages
  x  = pt(1,1);
  y  = pt(1,2);
  
end

data.it = it;
guidata(F,data);

