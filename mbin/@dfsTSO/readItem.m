function data = readItem(dm, itemno, v)
%DFSTSO/READITEM Read item data.
%
%   Read item data, for all or specified timesteps.
%
%   Usage:
%       data = readItem(dfs,i)     Read all timesteps of item
%       data = readItem(dfs,i,v)   Read only timesteps in v of item
%
%   input:
%      dfs        : dfs object
%      i          : Item number to read
%                   item numbers start from 1
%      v          : Vector holding index numbers to timesteps 
%                   timestep indeces start from 0
%
%   output:
%       data      : A vector containing data values for item
%
%   examples:
%       readItem(dfs,2)          : read data for all timesteps for item 2
%       readItem(dfs,2,5)        : read data for timestep 5 for item 2
%       readItem(dfs,2,5:10)     : read data for timestep 5 to 10
%       readItem(dfs,2,[5,7,10]) : read data for timestep 5, 7 and 10
%
%   note:
%       This function just wraps subscripted referencing to the data, i.e.,
%       calling 
%           data = readItem(dfs,2,5) 
%       is the same as using subcript indexing on the dfs object (see help
%       on DFSTSO/SUBSREF)
%           data = dfs(2,5)
%
%       See also DFSTSO/SUBSREF

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

% Check item argument
if (dm.TSO.Count == 0)
  error('dfsTSO:NoItemsDefined',...
    'File has currently no items defined');
end
if (dm.TSO.Time.NrTimeSteps == 0)
  error('dfsTSO:NoTimestepsDefined',...
    'File has currently no time steps defined');
end
if (~isscalar(itemno))
  error('dfsTSO:IndexError',...
    'First argument must be a scalar integer (item number)');
end
if (0 >= itemno)
  error('dfsTSO:IndexError',...
    'Item number must be positive, starting from 1');
end
if (itemno > dm.TSO.Count)
  error('dfsTSO:IndexError',...
    'Item number must be less than %i (number of items in file)',dm.TSO.Count);
end

%% Get all data for item
if (nargin < 3)
  data = dm.TSO.Item(itemno).GetData';
  return;
end

%% Check timestep argument
if (~isnumeric(v))
  error('dfsTSO:IndexError',...
    'Second argument must be an integer (vector) (timestep number)');
end
if (0 > min(v) || max(v) >= dm.TSO.Time.NrTimeSteps)
  error('dfsTSO:IndexError',[
    'All timestep indeces must non-negative and smaller than\n'...
    'the number of timesteps (ranging from 0 to %i)'],...
    dm.TSO.Time.NrTimeSteps-1);
end

%% Change timestep indeces from base 0 to base 1 indeces
v = v + 1;

%% Create correct data type
switch (dm.TSO.Item(itemno).DataType)
  case {'Type_Float'}  	       % 1 - 4 byte floating point number (float)
    data = zeros(length(v),1,'single');
  case {'Type_Double'} 	       % 2 - 8 byte floating point number (double)
    data = zeros(length(v),1,'double');
  case {'Type_Char'}           % 3 - 1 byte signed integer (char)
    data = zeros(length(v),1,'char');
  case {'Type_Int'}            % 4 - 4 byte signed integer (int)
    data = zeros(length(v),1,'int32');
  case {'Type_Unsigned'}       % 5 - 4 byte unsigned integer (unsigned int)
    data = zeros(length(v),1,'uint32');
  case {'Type_Short'}          % 6 - 2 byte signed integer (short)
    data = zeros(length(v),1,'int16');
  case {'Type_Unsigned_Short'} % 7 - 2 byte unsigned integer (unsigned short)
    data = zeros(length(v),1,'uint16');
end

%% Read data
if (length(v) < 1000)
  % Read the data at indeces specified by v
  for i = 1:length(v)
    data(i) = dm.TSO.Item(itemno).GetDataForTimeStepNr(v(i));
  end
else
  % Read all data and let Matlab pick out indeces specified by v
  % (A lot faster than above for large datasets)
  data = dm.TSO.Item(itemno).GetData';
  data = data(v(:));
end
