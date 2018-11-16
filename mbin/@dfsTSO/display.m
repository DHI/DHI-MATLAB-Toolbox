function display( dm )
%DFSTSO/DISPLAY Command window display of DFS file.
%
% Prints information of dfs file to the display.
%
% Called whenever a dfs id is entered at the command prompt, or returned
% from a function.

if (~isa(dm.TSO,dm.TSOPROGID))
  fprintf([inputname(1),' =\n   empty dfsTSO object\n']);
  return
end


disp([inputname(1),' = '])
fprintf('   filename            : %s\n',dm.TSO.Connection.FilePath);

% Spatial information
fprintf('   dimensions          : %i\n',1);

% Item information
fprintf('   number of items     : %i\n',dm.TSO.Count);
for i = 1:dm.TSO.Count
fprintf('            item %3i   : %-15s\n',i,dm.TSO.Item(i).Name);
end


% Get temporal information from file.
if (dm.TSO.Time.IsCalendar)
  datetime = [
    parseDatetimeString(dm.TSO.Time.StartTime);
    parseDatetimeString(dm.TSO.Time.EndTime)];
else
  datetime = [dm.TSO.Time.StartTime;dm.TSO.Time.EndTime];
end
% Get timestep information from file.
if (strcmp(dm.TSO.Time.TimeType,'Equidistant_Calendar') || ...
    strcmp(dm.TSO.Time.TimeType,'Equidistant_Relative'))
  timestepsec = ...
    dm.TSO.Time.TimeStep.ConvertStructToSecs(...
      dm.TSO.Time.TimeStep.Year,...
      dm.TSO.Time.TimeStep.Month,...
      dm.TSO.Time.TimeStep.Day,...
      dm.TSO.Time.TimeStep.Hour,...
      dm.TSO.Time.TimeStep.Minute,...
      dm.TSO.Time.TimeStep.Second,...
      dm.TSO.Time.TimeStep.Millisecond);
end

timeaxistype = dm.TSO.Time.TimeType;
% Temporal information
fprintf('   time axis type      : ');
switch (timeaxistype)
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
fprintf('   number of timesteps : %i\n',dm.TSO.Time.NrTimeSteps);

