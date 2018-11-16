%DFSCREATECUSTOMBLOCK Create Custom Block for dfs file.
%
%   Creates a custom block to be used when creating new dfs files. It is
%   required to use this method, to circumvent a bug in the DFS .NET
%   library from MIKE by DHI version 2011.
%
%   Usage:
%     cb = dfsCreateCustomBlock(factory, name, values, typeString)
%
%   Inputs:
%     factory    : A DfsFactory object.
%     name       : name of custom block
%     values     : values in custom block
%     typeString : The .NET Type string, 'System.Double', 'System.Single',
%                  'System.Int32' etc.
%
%   Outputs:
%     cb      : A custom block
%
%   Examples:
%     cb = dfsCreateCustomBlock(factory, 'Display Settings', [1,0,0], 'System.Double')
%     cb = dfsCreateCustomBlock(factory, 'Display Settings', [1,0,0], 'System.Uint32')

function cb = dfsCreateCustomBlock(factory, name, values, typeString)

% Get the .NET type of the factory
facType = factory.GetType();

% Find the generic version of CreateCustomBlock (it is the non-generic
% version which contains the bug)
methodInfo = findMethod(facType.GetMethods());

% Create a generic type argument
genericArgs = NET.createArray('System.Type',1);
genericArgs(1) = System.Type.GetType(typeString);
% Create the generic version of the methodInfo
genericMethodInfo = methodInfo.MakeGenericMethod(genericArgs) ;

% Create an array with the arguments
arr = NET.createArray('System.Object',2);
arr(1) = System.String(name);
arr(2) = NET.convertArray(values,typeString,numel(values));

% Call the generic CreateCustomBlock method by reflection
cb = genericMethodInfo.Invoke(factory, arr);



function mi = findMethod(typemethods)
mi = -1;
for i=1:typemethods.Length
 if (strcmp(char(typemethods(i).Name),'CreateCustomBlock') && typemethods(i).IsGenericMethod)
     mi = typemethods(i);
     return;
 end
end




