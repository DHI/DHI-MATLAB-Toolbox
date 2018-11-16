function datetime = parseDatetimeString(timestr)

try
  if (length(timestr) <= 8)
    datetime = datevec(timestr,'HH:MM:SS');
  elseif (length(timestr) <= 10)
    datetime = datevec(timestr,'dd-mm-yyyy');
  elseif (length(timestr) <= 12)
    datetime = datevec(timestr,'HH:MM:SS.FFF');
  elseif(length(timestr) <= 19)
    datetime = datevec(timestr,'dd-mm-yyyy HH:MM:SS');
  else
    datetime = datevec(timestr,'dd-mm-yyyy HH:MM:SS.FFF');
  end
catch
  error('DFSTSO:TimeNotParseable',...
    sprintf('Error while reading time information from file:\n%s\n%s',lasterr,timestr))
end
