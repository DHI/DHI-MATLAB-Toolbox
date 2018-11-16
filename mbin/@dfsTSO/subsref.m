function data = subsref(dm, S)
%DFSTSO/SUBSREF Subscripted reference.
%
%   Read data using subscripted referencing
%
%   Usage:
%       data = dfs(i)         Read all timesteps of item
%       data = dfs(i,v)       Read only timesteps in v of item
%
%   input:
%      i          : Item number to read
%                   item numbers start from 1
%                   or item name
%      v          : Vector holding index numbers to timesteps 
%                   timestep indeces start from 0
%
%   output:
%       data      : A vector containing data values for item
%
%   examples:
%       dfs(2)          : retrieve all timesteps for item 2
%       dfs(2,5)        : retrieve timestep 5 for item 2
%       dfs(2,5:10)     : retrieve timestep 5 to 10 for item 2
%       dfs(2,[5,7,10]) : retrieve timestep 5, 7 and 10 for item 2

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

if (strcmp(S(1).type,'()') || strcmp(S(1).type,'{}'))
  
  % Get item number
  if (~isnumeric(S(1).subs{1}))
      names = get(dm,'itemnames');
      found = false;
      for i=1:length(names)
          if strcmp(S(1).subs{1},names{i})
              S(1).subs{1} = i;
              found = true;
              break;
          end
      end
      if ~found
          possibleNames = '';
          for kk = 1:length(names)
              possibleNames = sprintf('%s\n%s',possibleNames,names{kk});
          end
        error('dfsTSO:IndexError','First index must be an integer (item number) or an item name\nYou wrote: %s\nPossible names are: %s',S(1).subs{1},possibleNames);
      end
  end
  itemno = S(1).subs{1};

  % Check whether to get entire item
  entire = 0;
  if (length(S(1).subs) == 1)
    entire = 1;
  elseif (length(S(1).subs) > 1)
    if (ischar(S(1).subs{2}))
      if (strcmp(S(1).subs{2},':'))
        entire = 1;
      else
        S = sprintf('Unknown index type for item timesteps: %s',S(1).subs{2});
        error('dfsTSO:IndexError',S);
      end
    end
  end

  % Read entire item
  if (entire)
    data = readItem(dm,itemno);
    return
  end
  
  if (~isnumeric(S(1).subs{2}))
    error('dfsTSO:IndexError','Second index must be an integer (vector) (timestep number)');
  end
  v = S(1).subs{2};
  % Read item
  data = readItem(dm,itemno,v);
  
end

