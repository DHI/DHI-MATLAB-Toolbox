function dm = subsasgn(dm, S, data)
%DFSTSO/SUBSASGN Subscripted reference assignment.
%
%   Write data using subscripted referencing
%
%   Usage:
%       dfs(i) = data         Write all timesteps of item
%       dfs(i,v) = data       Write only timesteps in v of item
%
%   input:
%      i          : Item number to read
%                   item numbers start from 1
%      v          : Vector holding index numbers to timesteps 
%                   timestep indeces start from 0
%       data      : A vector containing data values for item
%
%   See also DFSTSO/WRITEITEM

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

if (strcmp(S(1).type,'()') || strcmp(S(1).type,'{}'))
  
  % Get item number
  if (~isnumeric(S(1).subs{1}))
    error('dfsTSO:IndexError','First index must be an integer (item number)');
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

  % Write entire item
  if (entire)
    writeItem(dm,itemno,data);
    return
  end
  
  if (~isnumeric(S(1).subs{2}))
    error('dfsTSO:IndexError','Second index must be an integer (vector) (timestep number)');
  end
  v = S(1).subs{2};
  % write item
  writeItem(dm,itemno,v,data);
  
end

