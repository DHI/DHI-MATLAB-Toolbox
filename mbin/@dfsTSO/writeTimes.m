function writeTimes(dm,v,t)
%DFSTSO/WRITETIMES Write timestep times.
%
%   Write the time for timesteps. This is only possible for non-equidistant
%   time axis types. 
%
%   For equidistant time axis types, timestep times are controlled by the
%   startdate and timestep parameters. See dfsTSO/SET for how to
%   update timestep times for equidistant time axis files.
%
%   Setting a time value bigger than or equal to the next Timestep time
%   value or smaller than or equal to the previous Timestep time value is
%   not possible.
%
%   Usage:
%       writeTimes(dfs,t)    write all timestep times of file
%       writeTimes(dfs,v,t)  write timestep times of timesteps with indeces
%                            in v
%
%   Input:
%       v         : Vector holding index numbers to timesteps 
%                   timestep indeces start from 0
%       t         : A vector containing time values for each timestep
%                   For calendar type time axis, each row will contain 6
%                   columns (see help DATEVEC). For relative type time
%                   axis, each row will only contain 1 column.
%
%   Examples:
%       See DFSTSO/READTIMES for examples
%
%   Note:
%
%       Due to limitations in the COM layer of Matlab, calendar type time
%       axis are not fully supported: Milliseconds can not be read, times
%       will be rounded to nearest second.
%
%    See also DFSTSO/READTIMES, DFSTSO/SET

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

% Check time axis type
if (strcmp(dm.TSO.Time.TimeType,dm.TIMEAXISTYPES{2}) || ...
    strcmp(dm.TSO.Time.TimeType,dm.TIMEAXISTYPES{4}) )
  error('dfsTSO:TimeAxisIncompatible',[...
    'writeTimes can not update times for equidistant time axis types.\n'...
    'For equidistant time axis types, timestep times are controlled by the\n'...
    'startdate and timesteptime parameters. Use set(dfs) to update timestep\n'...
    'times for equidistant time axis files.'])
end

if (dm.TSO.Time.NrTimeSteps == 0)
  error('dfsTSO:NoTimestepsDefined',...
    'File has currently no timesteps defined');
end

%% Check index and time arguments
if (nargin == 2)
  if (size(v,1) ~= dm.TSO.Time.NrTimeSteps)
    error('dfsTSO:SizeMismatch','The number of rows in t and the number \nof timesteps must be the same')
  end
  t   = v;
  v   = 0:dm.TSO.Time.NrTimeSteps-1;
else
  % Remove duplicates and sort v
  [v,I] = unique(v);
  if (length(v) ~= size(t,1))
    error('dfsTSO:SizeMismatch',[
      'The number of rows in t and v must be the same\n'...
      'Repetitions in v is not allowed']);
  end
  % Permute t as v (from sorting)
  t(:,:) = t(I,:);
end
if (max(v) >= dm.TSO.Time.NrTimeSteps || min(v) < 0)
  error('dfsTSO:IndexError',...
    ['All timestep indeces must be greater than zero and smaller\n'...
    'than number of timesteps (ranging from 0 to %i)'],dm.TSO.Time.NrTimeSteps-1);
end
if (dm.TSO.Time.IsCalendar && size(t,2) ~= 6)
  error('dfsTSO:SizeMismatch',...
    ['Time input for calendar time axis must have 6 columns']);
end


%% Change timestep indeces from base 0 to base 1 indeces
v = v(:)+1;

%% Check timestep for increasing times
if (~issorted(t,'rows'))
  error('dfsTSO:TimeOrderError',...
    ['Time input must be increasing for increasing timestep numbers']);
end

if (dm.TSO.Time.IsCalendar)
  time_MIN = [0 0 0 0 0 0];
  time_MAX  = [9999 12 31 23 59 59];
else
  time_MIN = -inf;
  time_MAX = inf;
end

if (dm.TSO.Time.NrTimeSteps > 1)
  for i = 1:length(v)
    % Check if current time is between previous and next time
    if (i > 1 && (v(i-1) == v(i)-1))
      time_prev = t(i-1,:);
    elseif (v(i) == 1)
      time_prev = time_MIN;
    else
      time_prev = getTimeForTimestep(dm,v(i)-1);
    end
    if (i < length(v) && (v(i+1) == v(i)+1))
      time_next = t(i+1,:);
    elseif (v(i) == dm.TSO.Time.NrTimeSteps)
      time_next = time_MAX;
    else
      time_next = getTimeForTimestep(dm,v(i)+1);
    end
    if (~timeOrder(time_prev,t(i,:)) || ...
        ~timeOrder(t(i,:),time_next) )
      error('dfsTSO:TimeOrderError',...
        ['Time must be increasing for increasing timestep numbers\n'...
         'Time for timestep nr. %i is not increasing'],v(i)-1);
    end
  end
end

%% Write time information to existing file.
% Write to file
missing = 0;
for i = 1:length(v)

  if (v(i) == dm.TSO.Time.NrTimeSteps)
    time_next = time_MAX;
  else
    time_next = getTimeForTimestep(dm,v(i)+1);
  end

  if (timeOrder(t(i,:),time_next))

    % Order is ok, insert timestep time
    ti = t(i,:);
    vi = v(i);
    if (dm.TSO.Time.IsCalendar)
      dm.TSO.Time.SetTimeForTimeStepNr(vi,...
        COM.date(ti(1),ti(2),ti(3),ti(4),ti(5),ti(6)));
    else
      dm.TSO.Time.SetTimeForTimeStepNr(vi,ti);
    end
    
    % Insert missing timesteps
    for j = 1:missing
      ti = t(i-j,:);
      vi = v(i-j);     % should be v(i)-j
      if (dm.TSO.Time.IsCalendar)
        dm.TSO.Time.SetTimeForTimeStepNr(vi,...
          COM.date(ti(1),ti(2),ti(3),ti(4),ti(5),ti(6)));
      else
        dm.TSO.Time.SetTimeForTimeStepNr(vi,ti);
      end      
    end

  % Could not insert presently, continue and insert later.
  else
    missing = missing + 1;
  end
end



function t = getTimeForTimestep(dm,i)
if (dm.TSO.Time.IsCalendar)
  t = parseDatetimeString(dm.TSO.Time.GetTimeForTimeStepNr(i));
else
  t = dm.TSO.Time.GetTimeForTimeStepNr(i);
end

function ok = timeOrder(t1,t2)
if (size(t1,2) == 6)
  ok = datenum(t1) < datenum(t2);
else
  ok = t1 < t2;
end
