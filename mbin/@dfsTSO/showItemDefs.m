function showItemDefs(dm)
%DFSTSO/SHOWITEMDEFS Command window show of DFS file items.
%
%   Prints item name, EUMType name, and EUMUnit name to display.
%   
%   showItemDefs(dm)
%
if (~isa(dm.TSO,dm.TSOPROGID))
  error('dfsTSO:Empty',[inputname(1),' is an empty dfsTSO object']);
  return
end

fprintf('   #items   : %i\n',dm.TSO.Count);
for i = 1:dm.TSO.Count
fprintf('item %3i\n',i);
fprintf('   Name     : %s \n',dm.TSO.Item(i).Name);
fprintf('   EUMType  : %s \n',dm.TSO.Item(i).EumTypeDescription);
fprintf('   EUMUnit  : %s \n',dm.TSO.Item(i).EumUnitAbbreviation);
end
