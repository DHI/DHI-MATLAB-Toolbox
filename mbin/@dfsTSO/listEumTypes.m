function l = listEumTypes(dm)
%DFSTSO/LISTEUMTYPES List available EUM Type strings.
%
%   List the EUM types that are available
%
%   Usage:
%       l = listEumTypes(dfs)
%
%   Input:
%       dfs    : DFS object
%
%   Output:
%       l      : A list of all available types
%
%   Example:
%       If you do not have a DFS object, you may use a new empty object as
%       the argument:
%           l = listEumTypes(dfsTSO())
%
%   See also DFSTSO/listEumUnits, DFSTSO/setItemEum

item = actxserver('TimeSeries.TSItem');
l    = item.GetEumTypes;
item.release;