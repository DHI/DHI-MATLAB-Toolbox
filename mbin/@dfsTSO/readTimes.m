function t = readTimes(dm,v)
%DFSTSO/READTIMES Read timestep times.
%
%   Reads the time for timesteps
%
%   Usage:
%       t = readTimes(dfs)      Read all timestep times of file
%       t = readTimes(dfs,v)    Read only timestep times in v of file
%
%   Input:
%       dfs       : dfsTSO object
%       v         : Vector holding index numbers to timesteps 
%                   timestep indeces start from 0
%
%   Output:
%       t         : A vector containing time values for each timestep
%                   For calendar type time axis, each row will contain 6
%                   columns (see help DATEVEC). For relative type time
%                   axis, each row will only contain 1 column.
%
%   Examples:
%       readTimes(dfs)          : retrieve all timesteps
%       readTimes(dfs,5)        : retrieve timestep 5
%       readTimes(dfs,5:10)     : retrieve timesteps 5 to 10
%       readTimes(dfs,[5,7,10]) : retrieve timesteps 5, 7 and 10
%
%   Note:
%       Due to limitations in the COM layer of Matlab, calendar type time
%       axis are not fully supported: Milliseconds can not be read, times
%       will be rounded to nearest second. Furthermore, performance is bad
%       for Calendar type time axis.

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

all = 0;
if (nargin == 1)
  v   = 0:dm.TSO.Time.NrTimeSteps-1;
  all = 1;
else
  if (max(v) >= dm.TSO.Time.NrTimeSteps || min(v) < 0)
    error('dfsTSO:IndexError',...
      ['All timestep indeces must be greater than zero and smaller\n'...
      'than number of timesteps (ranging from 0 to %i)'],dm.TSO.Time.NrTimeSteps-1);
  end
end

% Change timestep indeces from base 0 to base 1 indeces
v = v+1;

% Get time information from existing file.
% For Calendar type time axis, Matlab converts a COM VT_Date to a variable
% sized string depending on the date/time values and does not include
% milliseconds (as of Matlab version 7.3)
if (dm.TSO.Time.IsCalendar)
  t = zeros(length(v),6);

  % Equidistant time, calculate from starttime and timestepsec
  if (strcmp(dm.TSO.Time.TimeType,dm.TIME_EQ_CAL))
    % Read starttime and timestep in seconds
    tstartnum = datenum(parseDatetimeString(dm.TSO.Time.StartTime));
    tstepsec  = readTimestepSec(dm);
    % Create times, round off to nearest millisecond
    t         = datevec(tstartnum+((v-1)*tstepsec+0.0005)/(24*60*60));
    t(:,6)    = floor(t(:,6)*1000)*0.001; 

  % Non-equidistant, read all from file (bad performance)
  else
    for i = 1:length(v)
      timestr = dm.TSO.Time.GetTimeForTimeStepNr(v(i));
      t(i,:) = parseDatetimeString(timestr);
    end
  end

else
  t = zeros(length(v),1);
  if (all)
    t = dm.TSO.Time.GetTime';
  elseif (length(v)<1000)
    % Read the time at indeces specified by v
    for i = 1:length(v)
      t(i) = dm.TSO.Time.GetTimeForTimeStepNr(v(i));
    end
  else
    % Read all times and let Matlab pick out indeces specified by v
    % (A lot faster than above for large datasets)
    t = dm.TSO.Time.GetTime';
    t = t(v(:));
  end

end

