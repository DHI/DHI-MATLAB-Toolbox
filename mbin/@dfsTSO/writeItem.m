function writeItem(dm, itemno, v, data)
%DFSTSO/WRITEITEM Write item data.
%
%   Write item data to object. Data will only be saved to file when
%   save(dfs) is issued.
%
%   Usage:
%       writeItem(dfs,i,data)     write all timesteps of item
%       writeItem(dfs,i,v,data)   write only timesteps in v of item
%
%   Input:
%       dfs       : dfs object
%       i         : Item number to read
%                   item numbers start from 1
%       v         : Vector holding index numbers to timesteps 
%                   timestep indeces start from 0
%       data      : Vector holding data of item
%
%   Examples:
%       See DFSTSO/READITEM for examples of inputs
%
%   Note:
%       You may use subscripted referencing, since calling 
%           writeItem(dfs,2,5,data) 
%       is the same as using subcript references on the dfs object (see
%       help on DFSTSO/SUBSREF)
%           dfs(2,5) = data
%
%       See also DFSTSO/SUBSREF, DFSTSO/READITEM


% Check item argument
if (~isscalar(itemno))
  error('dfsTSO:IndexError','First argument must be a scalar integer (item number)');
end
if (0 >= itemno)
  error('dfsTSO:IndexError','Item number must be positive, starting from 1');
end
if (itemno > dm.TSO.Count)
  error('dfsTSO:IndexError','Item number must be less than %i (number of items in file)',dm.TSO.Count);
end

if (nargin == 3)
  data = v;
  clear v;
end


% Check data type, and convert if necessary
switch (dm.TSO.Item(itemno).DataType)
  case {'Type_Float'}  	       % 1 - 4 byte floating point number (float)
    if (~strcmp(class(data),'single'))
      warning('dfsTSO:TypeMismatchConversion','Conversion from %s to single - possible loss of data',class(data));
      data = single(data);
    end
  case {'Type_Double'} 	       % 2 - 8 byte floating point number (double)
    if (~strcmp(class(data),'double'))
      warning('dfsTSO:TypeMismatchConversion','Conversion from %s to double - possible loss of data',class(data));
      data = double(data);
    end
  case {'Type_Char'}           % 3 - 1 byte signed integer (char)
    if (~strcmp(class(data),'char'))
      warning('dfsTSO:TypeMismatchConversion','Conversion from %s to char - possible loss of data',class(data));
      data = char(data);
    end
  case {'Type_Int'}            % 4 - 4 byte signed integer (int)
    if (~strcmp(class(data),'int32'))
      warning('dfsTSO:TypeMismatchConversion','Conversion from %s to int32 - possible loss of data',class(data));
      data = int32(data);
    end
  case {'Type_Unsigned'}       % 5 - 4 byte unsigned integer (unsigned int)
    if (~strcmp(class(data),'uint32'))
      warning('dfsTSO:TypeMismatchConversion','Conversion from %s to uint32 - possible loss of data',class(data));
      data = uint32(data);
    end
  case {'Type_Short'}          % 6 - 2 byte signed integer (short)
    if (~strcmp(class(data),'int16'))
      warning('dfsTSO:TypeMismatchConversion','Conversion from %s to int16 - possible loss of data',class(data));
      data = int16(data);
    end
  case {'Type_Unsigned_Short'} % 7 - 2 byte unsigned integer (unsigned short)
    if (~strcmp(class(data),'uint16'))
      warning('dfsTSO:TypeMismatchConversion','Conversion from %s to uint16 - possible loss of data',class(data));
      data = uint16(data);
    end
end


% write data for all timesteps
if (nargin == 3)
  if (length(data) ~= dm.TSO.Time.NrTimeSteps)
    error('dfsTSO:SizeMismatch','The number of elements in data and the number \nof timesteps must be the same')
  end
  for i=1:dm.TSO.Time.NrTimeSteps
    dm.TSO.Item(itemno).SetDataForTimeStepNr(i,data(i))
  end
  return;
end


% Check timestep indeces and size compared with data
if (~isnumeric(v))
  error('dfsTSO:IndexError','Second argument must be an integer (vector) (timestep number)');
end
if (0 > min(v) || max(v) >= dm.TSO.Time.NrTimeSteps)
  error('dfsTSO:IndexError',[
    'All timestep indeces must non-negative and smaller than number of timesteps\n'...
    '(ranging from 0 to %i)'],dm.TSO.Time.NrTimeSteps-1);
end
if (length(v) ~= length(data))
  error('dfsTSO:IndexError','The number of elements in v and data must be the same.');
end

% Change from base 0 to base 1 indeces
v = v + 1;

% write data
for i = 1:length(v)
  dm.TSO.Item(itemno).SetDataForTimeStepNr(v(i),data(i));
end
