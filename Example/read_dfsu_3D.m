% Example of how to plot data from a dfsu 3D file.
%
% Plotting dfsu data in Matlab can not be done directly. The reason is that
% standard Matlab triangular plotting routines are based on node values,
% while the dfsu files contain element center values, and contains a 
% mis of triangles and quadrilaterals. For 3D dfsu files, this is 
% even more tricky than for 2D files (see read_dfsu_2D.m)
%
% We will use that data values, element center coordinates and the element
% connectivity matrix, are ordered in "layer major order", meaning that if
% there is 5 layers in the file, then element 1 to 5 will be right on top
% of each other. There will be one node layer more than number element
% layers.

%% For Mike software release 2017 or older, comment the following three lines:
NET.addAssembly('DHI.Mike.Install');
import DHI.Mike.Install.*;
MikeImport.Setup(MikeMajorVersion.V17, [])

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

dfsu3 = DfsFileFactory.DfsuFileOpen('data/data_odense_3D.dfsu');

% Node coordinates
xn = double(dfsu3.X);
yn = double(dfsu3.Y);
zn = double(dfsu3.Z);

% Create element table in Matlab format

tn3D = mzNetFromElmtArray(dfsu3.ElementTable);
% also calculate element center coordinates
[xe,ye,ze] = mzCalcElmtCenterCoords(tn3D,xn,yn,zn);

% Read some item information
items = {};
for i = 0:dfsu3.ItemInfo.Count-1
   item = dfsu3.ItemInfo.Item(i);
   items{i+1,1} = char(item.Name);
   items{i+1,2} = char(item.Quantity.Unit);
   items{i+1,3} = char(item.Quantity.UnitAbbreviation); 
end

nsteps = dfsu3.NumberOfTimeSteps;

nlayers = dfsu3.NumberOfLayers;

% Extract top and bottom layer. Take every nlayers element
% starting from 1 and nlayers respectively
tn3D_bot = tn3D(1:nlayers:end,:);
tn3D_top = tn3D(nlayers:nlayers:end,:);

% number of elements in 2D
nel2D = size(tn3D_bot,1);

% Quads in 2D mesh
q2D = tn3D_bot(:,7) > 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract top and bottom node layer from 3D data (surface and bathymetry).
% Pick the bottom and top nodes for the elements. 
% To select top node layer of element, pick column 4:6 for triangles 
% and 5:8 for quads. To select bottom node layer of element, pick 
% column 1:3 and 1:4 respectively.
tn_bot = zeros(nel2D,4);
tn_bot(q2D,:) = tn3D_bot(q2D,1:4);      % Extract 2D quads, bottom layer
tn_bot(~q2D,1:3) = tn3D_bot(~q2D,1:3);  % Extract 2D triangles, bottom layer
tn_top = zeros(nel2D,4);
tn_top(q2D,:) = tn3D_top(q2D,5:8);      % Extract 2D quads, top layer
tn_top(~q2D,1:3) = tn3D_top(~q2D,4:6);  % Extract 2D triangles, top layer
tn     = [tn_bot;tn_top];
% Plot top and bottom node layer.
figure(1), clf
mzPlot(tn,xn,yn,zn,zn)
colorbar
view(45,20)
title(sprintf('Top and bottom node layer\n(surface and bathymetry) at simulation start'))


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract 2D mesh from 3D data, based on bottom layer (layer 1)
% Node coordinates
xn2D = xn(1:nlayers+1:end);
yn2D = yn(1:nlayers+1:end);
zn2D = zn(1:nlayers+1:end);
% 2D element connectivity matrix
I = tn_bot == 0;
tn2D   = (tn_bot-1)/double(nlayers+1)+1;
tn2D(I) = 0;
% Plot 2D mesh
figure(2), clf
mzPlot(tn2D,xn2D,yn2D,zn2D,zn2D)
title(sprintf('Bathymetry from above\n(Try to rotate)'))
colorbar
view(2);

% Now we can work on the 3D dfsu file one layer at a time, using same
% techniques as in 2D.

% Delete value only available from Release 2012 and later
if (mzMikeVersion() >= 2012)
  deleteval = double(dfsu3.DeleteValueFloat);
else
  deleteval =  double(single(1.0000e-35));
end

figure(3), clf
for i=0:nsteps-1

  % Load data 3D
  Z      = double(dfsu3.ReadItemTimeStep(1,i).Data);
  curs   = double(dfsu3.ReadItemTimeStep(2,i).Data);
  salt   = double(dfsu3.ReadItemTimeStep(4,i).Data);

  % Reshape to 2D, with each column in the mesh having its own column
  salt = reshape(salt,nlayers,numel(salt)/nlayers);
  curs = reshape(curs,nlayers,numel(curs)/nlayers);
  Z = reshape(Z,nlayers+1,numel(Z)/(nlayers+1));
  
  % Pick layer (change ilayer to plot another layer)
  ilayer = 1;
  salt2D = salt(ilayer,:)';
  curs2D = curs(ilayer,:)';
  
  % Remove delete values, set them to NaN, since NaN's do not show up on the plots
  I = find(salt2D == deleteval);
  salt2D(I) = NaN;
  curs2D(I) = NaN;
  
  salplot = true;
  if (salplot)
    % Plot 2D result - Z and salinity
    mzPlot(tn_top,xn-2.11e+005,yn-6.15e+006,Z,salt2D);
    set(gca,'clim',[3,18])
    set(gca,'zlim',[-0.3,0.5])
    axis normal
    title(sprintf('Surface elevation, colored by %s (%s), step %i, layer %i',...
                  items{3,1},items{3,3},i,ilayer));
  else
    % Plot 3D result - currentspeed
    mzPlot(tn3D,xn,yn,curs,nlayers,ilayer);
    title(sprintf('%s (%s)\nstep %i, layer %i',...
                  items{1,1},items{1,3},i,ilayer));
  end
  
  colorbar;
  view(40,20);
  drawnow;
  pause(0.1);

end

dfsu3.Close();
