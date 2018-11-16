function dm = removeTimesteps(dm,v)
%DFSTSO/REMOVETIMESTEPS Remove timesteps from file.
%
%   Remove timesteps with indeces in v from file. 
%
%   For calendar type time axis, only timesteps at the beginning or the end
%   can be removed.
%
%   Usage:
%       removeTimesteps(dfs,v)
%
%   Inputs:
%       dfs : DFS object
%       v   : Vector with timestep indeces, zero based.
%
%   Note:
%       removeTimesteps affects all items of the file since number of data
%       elements in an item is always equal to Number of timesteps, which
%       is updated by addTimesteps. Item data values for removed timesteps
%       are deleted.
%
%       Changes are first made to the file when save(dfs) is issued.


if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

% Sort and remove duplicate indeces
v = unique(v); 

% Check argument
if (v(end) >= dm.TSO.Time.NrTimeSteps || v(1) < 0)
  error('dfsTSO:IndexError',...
    ['All timestep indeces must be greater than zero and smaller\n'...
    'than number of timesteps (ranging from 0 to %i)'],dm.TSO.Time.NrTimeSteps-1);
end

%% Remove timesteps for equidistant time axis
if (strcmp(dm.TSO.Time.TimeType,dm.TIMEAXISTYPES{2}) || ...
    strcmp(dm.TSO.Time.TimeType,dm.TIMEAXISTYPES{4}) )

  % Check for equidistant time axis that v is beginning or end of file.
  if (max(diff(v)) > 1 || ...
      v(1) ~= 0 && v(end) ~= dm.TSO.Time.NrTimeSteps-1)
    error('dfsTSO:removeCalendarTimesteps',[...
      'For calendar type time axis, only timesteps at the beginning or\n'...
      'the end can be removed.']);
  end

  % When removing from start, remove the first time step length(v) times
  if v(1) == 0
    for i = 1:length(v)
      dm.TSO.Time.RemoveTimeStepNr(1);
    end
    return
  else
    for i = 1:length(v)
      dm.TSO.Time.RemoveTimeStepNr(dm.TSO.Time.NrTimeSteps);
    end
  end

%% Remove timesteps for non-equidistant time axis
else

  % Change timestep indeces from base 0 to base 1 indeces
  v = v+1;

  % Remove largest timesteps first
  for i = length(v):-1:1
    dm.TSO.Time.RemoveTimeStepNr(v(i));
  end
  
end
