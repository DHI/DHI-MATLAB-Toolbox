function [vals, outInfos] = res11read(infile, extractPoints,chainagetol)
%RES11READ Extract time series data from res11 file.
%
%   Reads data from a .res11 file, extracting time series for specified
%   quantity, branch and chainage specifications. Matches the functionality
%   of the res11read.exe. 
%
%   For more flexible access to res11 results, check out the read_Network.m
%   example.
%
%   Usage: Setup extractPoints and call res11read, example here extracts
%          two water levels and one discharge time series
%
%     extractPoints{1}.branchName = 'VIDAA-NED';
%     extractPoints{1}.quantity = 'Water Level';
%     extractPoints{1}.chainages = [10000, 11300];
%     extractPoints{2}.branchName = 'VIDAA-NED';
%     extractPoints{2}.quantity = 'Discharge';
%     extractPoints{2}.chainages = 10128;
%     [values,outInfos] = res11read(infile,extractPoints)
%
%     [values,outInfos] = res11read(infile,extractPoints,chainagetol)
%
%   Inputs:
%     infile        : File name of res11 file
%     extractPoints : A specification of where to extract time series
%     chainagetol   : Tolerance value in meters for finding chainages. 
%                     Default (if left out) is 1 m.
%
%   Outputs:
%     vals     : Time series values at extract points
%     outInfos : Info of extracted time series quantities

% Copyright, DHI, 2010-08-20. Author: JGR
%

NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
import DHI.Generic.MikeZero.DFS.*;

if (nargin <= 2)
  chainagetol = 1;
end

%% Open res11 file
res11File  = DfsFileFactory.DfsGenericOpen(infile);

%% Reading item info
itemInfos = {};
for ii = 1:res11File.ItemInfo.Count
    itemInfo = res11File.ItemInfo.Item(ii-1);
    % item name is on the form: Quantity, branchName chainagefrom-to
    % example: Water Level, VIDAA-NED 8775.000-10800.000
    itemName = char(itemInfo.Name);
    % Split on ', ' - seperates quantity and branch
    split = regexp(itemName,', ','split');
    itemQuantity = split{1};
    branch = split{2};
    % Branch name and chainages are split on the last ' '
    I = find(branch == ' ');
    I1 = I(end);
    branchName = branch(1:I1-1);
    
    % Read spatial axis of item and extract chainages. 
    % The chainages values are grid point chainages. For Discharge items
    % these will not cover the entire branch chainage span.
    coords = itemInfo.SpatialAxis.Coordinates;
    chainages = zeros(coords.Length,1);
    for i=1:coords.Length
        % chainage is stored as X coordinate
        chainages(i) = coords(i).X;
    end

    % Storing information on items in Matlab format
    itemInfos{ii}.branchName = branchName;
    itemInfos{ii}.chainages = chainages;
    itemInfos{ii}.quantity = itemQuantity;
    itemInfos{ii}.eumquantity = itemInfo.Quantity;
    itemInfos{ii}.Read = false;   % true if this should be read
    itemInfos{ii}.indices = [];   % indices of data to extract
    itemInfos{ii}.readOrder = []; % index into extracted timeseries matrix
    % Print out item info
    %fprintf('Name: %s. Name: %s, %d - %d\n',itemName, branchName, chainages(1), chainages(end));
    
end

%% Search for extractPoints in itemInfos
readOrder = 0;
outInfos = {};
for ii = 1:numel(extractPoints)
   extractPoint = extractPoints{ii};
   
   % Looping over possibly several chainage values
   for ch = extractPoints{ii}.chainages
      found = false;
      
      % Searching in all itemInfos
      minchdiffmin = 1000000;
      minchdiffch = 0;
      for iitem = 1:numel(itemInfos)
         itemInfo = itemInfos{iitem};
         if (~strcmpi(extractPoint.quantity,itemInfo.quantity)) 
             continue; % quantity does not match
         end
         if (~strcmpi(extractPoint.branchName,itemInfo.branchName)) 
             continue; % branch name does not match
         end
         [minchdiff,minchI] = min(abs(itemInfo.chainages-ch));
         if (minchdiff < minchdiffmin)
           % Store closest chainage, for error reporting
           minchdiffmin = minchdiff;
           minchdiffch = itemInfo.chainages(minchI);
         end
         if (minchdiff > chainagetol)
             continue; % chainage value not found within tolerance
         end
         % extractPoint was found, store outInfos, index and order
         readOrder = readOrder + 1;
         outInfos{readOrder}.quantity = itemInfo.quantity;
         outInfos{readOrder}.eumquantity = itemInfo.eumquantity;
         outInfos{readOrder}.branchName = itemInfo.branchName;
         outInfos{readOrder}.chainage = ch;
         itemInfos{iitem}.Read = true;
         itemInfos{iitem}.indices = [itemInfos{iitem}.indices;minchI];
         itemInfos{iitem}.readOrder = [itemInfos{iitem}.readOrder;readOrder];
         found = true;
         break;
      end
      if (~found)
        if(minchdiffmin == 1000000)
          fprintf('Did not find extract point %i, chainage %f. No branch with name "%s"\n',ii,ch,extractPoint.branchName);
        else
          fprintf('Did not find extract point %i, chainage %f. Closest chainage at %f\n',ii,ch,minchdiffch);
        end
      end
   end
end

%% Read data from file and store in vals
res11File.Reset();
vals = zeros(res11File.FileInfo.TimeAxis.NumberOfTimeSteps,readOrder);
for i=1:res11File.FileInfo.TimeAxis.NumberOfTimeSteps
   for iitem=1:res11File.ItemInfo.Count
       if (itemInfos{iitem}.Read)
           % Timestep is index, hence subtract 1
           dd = double(res11File.ReadItemTimeStep(iitem, i-1).Data);
           % Store the indexed values in vals, in the correct columns
           vals(i, itemInfos{iitem}.readOrder) = dd(itemInfos{iitem}.indices);
       end
   end
end

res11File.Close();



