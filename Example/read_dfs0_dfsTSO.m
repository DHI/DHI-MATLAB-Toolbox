% A script loading a dfs0 file and plotting the time series, using the
% dfsTSO object.

infile = 'data/data_ndr_roese.dfs0';

if (~exist(infile,'file'))
  [filename,filepath] = uigetfile('*.dfs0','Select the .dfs0');
  infile = [filepath,filename];
end

dfs0  = dfsTSO(infile)

% Read times and make a date axis (removing year and month)
t = readTimes(dfs0);    % This is a bit slow
t = datenum(t)-datenum([1993 12 0]);

itemnames = get(dfs0,'itemnames');

% Plot the first 4 items of the file in each subplot
for i=1:4
  subplot(2,2,i);
  plot(t,dfs0(i));
  title(itemnames{i});
  axis tight
end
shg;

close(dfs0);


