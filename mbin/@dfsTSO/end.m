function e = end(dm, k, n)
%DFSTSO/END Subscripted reference end.
%
%   Get last index of subscripted reference.
%

if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

switch (k)
  case {1}
    e = dm.TSO.Count;
  case {2}
    e = dm.TSO.Time.NrTimeSteps-1;
end
