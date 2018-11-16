function dm = dfsTSO( a , create)
%DFSTSO Create new dfsTSO object for dfs0 files.
%
%   opens a new DFS file using filename and returns an object for handling
%   the file.
%
%   Usage:
%      dfs = dfsTSO( filename )
%      dfs = dfsTSO( filename , create )
%
%   Inputs:
%      filename : name of file
%      create   : Set to 1 if creating new file
%
%   Outputs:
%      dfs      : A matlab object holding the file

% Version 0.4, 2007-01-13, JGR


% Constants
dm.TIME_UNDEF       = 'undefined';
dm.TIME_EQ_REL      = 'Equidistant_Relative';
dm.TIME_NONEQ_REL   = 'Non_Equidistant_Relative';
dm.TIME_EQ_CAL      = 'Equidistant_Calendar';
dm.TIME_NONEQ_CAL   = 'Non_Equidistant_Calendar';
dm.TIMEAXISTYPES = {
  dm.TIME_UNDEF;
  dm.TIME_EQ_REL;
  dm.TIME_NONEQ_REL;
  dm.TIME_EQ_CAL;
  dm.TIME_NONEQ_CAL};
dm.ITEMVALUETYPES = {
  'Instantaneous';
  'Accumulated';
  'Step_Accumulated';
  'Mean_Step_Accumulated';
  'Reverse_Mean_Step_Accumulated'};

dm.TSOPROGID = 'COM.TimeSeries_TSObject';

  
% Variables in object (new/empty file parameters)
dm.TSO = 0;
dm.datetime = zeros(0,1);
dm.timestepsec = -1;

% Check input parameters
filename = '';
if nargin < 2
  create = 0;
end
if nargin == 1 && isa(a,'dfsTSO')
  dm = a;
  return;
end

if (nargin == 0)
  filename = 'dfsTSO_new.dfs0'; % Empty new file filename
  create   = 1;
elseif (nargin >= 1 && ischar(a))
  filename = a;
elseif nargin == 1 && isa(a,'COM.TimeSeries_TSObject')
  dm.TSO = a;
  dm = class(dm,'dfsTSO');
  return;
else
  error('dfsTSO:WrongInput','Wrong input arguments');
end

% Create COM/ActiveX automation server
try
  dm.TSO = actxserver('TimeSeries.TSObject');
catch
  error('dfsTSO:TSONotInitiated',[
    'Could not initiate TimeSeries handler. Make sure the DHI MIKE\n'...
    'Objects Timeseries Package is installed on your computer\n\n%s'...
    ],lasterr)
end

% Set filename/path
dm.TSO.Connection.FilePath = filename;

% Check new file name
if (create && dm.TSO.Connection.FileExists)
  error('dfsTSO:FileExist','File already exists, can not create as new.');
end

% Validate and open existing file
if ( ~create)
  if (exist(dm.TSO.Connection.FilePath) == 0)
  %if (~dm.TSO.Connection.FileExists) % !!! not working?!?
    filename(find(filename=='\')) = '/';
    error('dfsTSO:FileNotFound',...
      ['The file was not found: ' filename])
  elseif (~dm.TSO.Connection.IsFileValid)
    filename(find(filename=='\')) = '/';
    error('dfsTSO:FileNotValid',...
      ['The file is not a valid TimeSeries file: ',filename])
  end

  dm.TSO.Connection.Open;

% Create new file parameters
else
  % Set start time
  nowvec = datevec(now);
  dm.TSO.Time.StartTime = COM.date(nowvec(1),nowvec(2),nowvec(3));
  
end
  
dm = class(dm,'dfsTSO');

