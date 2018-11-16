function display( dm )
%DFS/DISPLAY Command window display of DFS file.
%
% Prints information of dfs file to the display.
%
% Called whenever a dfs object is entered at the command prompt, or returned
% from a function.

% Version 1, 2014-02-02, JGR

if (~isa(dm.dfsFile, 'DHI.Generic.MikeZero.DFS.IDfsFile'))
  fprintf([inputname(1),' =\n   empty DFS object\n']);
  return
end

disp([inputname(1),' = '])
fprintf('   filename            : %s\n',char(dm.dfsFile.FileName));

% Item information
fprintf('   number of items     : %i\n',dm.dfsFile.ItemInfo.Count);
for i = 1:dm.dfsFile.ItemInfo.Count
fprintf('            item %3i   : %-15s\n',i,char(dm.dfsFile.ItemInfo.Item(i-1).Name));
end

%% Get temporal information from file.
timeAxis = dm.dfsFile.FileInfo.TimeAxis;
timeAxisType = int32(timeAxis.TimeAxisType);
timespan = DHI.Generic.MikeZero.DFS.DfsExtensions.TimeSpanInSeconds(timeAxis);
if (timeAxisType == dm.TIME_EQ_CAL || timeAxisType == dm.TIME_NONEQ_CAL)
  dts = timeAxis.StartDateTime;
  dte = dts.AddSeconds(timespan);
  datetime = [ [dts.Year, dts.Month, dts.Day, dts.Hour, dts.Minute, dts.Second];
               [dte.Year, dte.Month, dte.Day, dte.Hour, dte.Minute, dte.Second]];
else
  datetime = [timeAxis.StartTimeOffset ; timeAxis.StartTimeOffset+timespan];
end

% Get timestep information from file.
if (timeAxisType == dm.TIME_EQ_CAL || timeAxisType == dm.TIME_EQ_TIME)
  timestepsec = DHI.Generic.MikeZero.DFS.DfsExtensions.TimeStepInSeconds(timeAxis);
end

% Temporal information
fprintf('   time axis type      : ');
switch (timeAxisType)
  case {dm.TIME_UNDEF}
fprintf('undefined time axis\n')
  case {dm.TIME_EQ_REL}
fprintf('Relative time axis, equidistant\n');
fprintf('   starttime           : %6.3f\n',datetime(1));
fprintf('   endtime             : %6.3f\n',datetime(end));
fprintf('   timestep interval   : %10.3f (seconds)\n',timestepsec);
  case {dm.TIME_NONEQ_REL}
fprintf('Relative time axis, non-equidistant\n');
fprintf('   starttime           : %6.3f\n',datetime(1));
fprintf('   endtime             : %6.3f\n',datetime(end));
fprintf('   timestep interval   : Varying\n');
  case {dm.TIME_EQ_CAL}
fprintf('Calendar time axis, equidistant\n');
fprintf('   startdate           : %04i-%02i-%02i %02i:%02i:%06.3f\n',datetime(1,:));
fprintf('   enddate             : %04i-%02i-%02i %02i:%02i:%06.3f\n',datetime(end,:));
fprintf('   timestep interval   : %10.3f (seconds)\n',timestepsec);
  case {dm.TIME_NONEQ_CAL}
fprintf('Calendar time axis, non-equidistant\n');
fprintf('   startdate           : %04i-%02i-%02i %02i:%02i:%06.3f\n',datetime(1,:));
fprintf('   enddate             : %04i-%02i-%02i %02i:%02i:%06.3f\n',datetime(end,:));
fprintf('   timestep interval   : Varying\n');
  otherwise
fprintf('undefined unknown time axis\n')    
end
fprintf('   number of timesteps : %i\n',dm.dfsFile.FileInfo.TimeAxis.NumberOfTimeSteps);

