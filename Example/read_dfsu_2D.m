% Example of how to plot dfsu 2D data. It will plot the water levels and
% color the mesh based on current speed.
%
% About plotting
% ==============
% Plotting raw unstructed dfsu data in Matlab can not be done directly. The
% reason is that standard Matlab triangular plotting routines are based on
% node values (finite element data), while the dfsu files contain element
% center values (finite volume data). There are two ways to plot dfsu data
% in Matlab: 
%
%     1) Create a triangular mesh based on element center nodes.
%     2) Interpolate element center values to node positions.
%     3) Use the mzPlot routine
%
% There are routines included in the DHI Matlab toolbox that will make both
% of the two first solutions possible, the third is straight forward. This
% example will show all of them.
%
% If having a mixed mesh of triangles and quadrilaterals, only the mzPlot
% method works.

% %For MIKE software release 2019 or 2020, the following is required to find the MIKE installation files
% dmi = NET.addAssembly('DHI.Mike.Install');
% if (~isempty(dmi)) 
%   DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
% end

NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
import DHI.Generic.MikeZero.DFS.*;

infile = 'data/data_oresund_2D.dfsu';

if (~exist(infile,'file'))
  [filename,filepath] = uigetfile('*.dfsu','Select the .dfsu file to analyse');
  infile = [filepath,filename];
end

dfsu2 = DfsFileFactory.DfsuFileOpen(infile);

% Node coordinates
xn = double(dfsu2.X);
yn = double(dfsu2.Y);
zn = double(dfsu2.Z);

% Create element table in Matlab format
tn = mzNetFromElmtArray(dfsu2.ElementTable);
% also calculate element center coordinates
[xe,ye,ze] = mzCalcElmtCenterCoords(tn,xn,yn,zn);

% Read some item information
items = {};
for i = 0:dfsu2.ItemInfo.Count-1
   item = dfsu2.ItemInfo.Item(i);
   items{i+1,1} = char(item.Name);
   items{i+1,2} = char(item.Quantity.Unit);
   items{i+1,3} = char(item.Quantity.UnitAbbreviation); 
end

nsteps = dfsu2.NumberOfTimeSteps;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot based on element center values
figure(1), clf, shg
% When using element center values, we need to triangulate these, but we
% can directly plot the raw data
t = mzTriangulateElmtCenters(xe,ye,tn);

for i=0:nsteps-1

  % Load data
  h = double(dfsu2.ReadItemTimeStep(1,i).Data)';
  s = double(dfsu2.ReadItemTimeStep(4,i).Data)';
  
  % Plot result using standard Matlab triangular plotting routine
  H = trisurf(t,xe,ye,h,s);

  % Make plot look nice
  shading interp
  axis tight
  set(gca,'DataAspectRatio',[1,1,1/20000],'clim',[0,1],'zlim',[-1,0.5])
  title(sprintf('%s (%s), color using %s (%s)\nstep %i (element values)',...
                items{1,1},items{1,3},items{4,1},items{4,3},i));
  view(-25,15);
  colorbar
  drawnow;
  pause(0.05);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot based on interpolated node values
figure(2), clf, shg
NtoE = tritables(tn);

for i=0:nsteps-1

  % Load data
  h = double(dfsu2.ReadItemTimeStep(1,i).Data)';
  s = double(dfsu2.ReadItemTimeStep(4,i).Data)';

  % For each time step we have to calculate node values from element center
  % values - it may take a while
  tic;
  [hn] = mzCalcNodeValues(tn,xn,yn,h,xe,ye,NtoE);
  [sn] = mzCalcNodeValues(tn,xn,yn,s,xe,ye,NtoE);
  fprintf('Took %f seconds to calculate node values\n',toc)
  
  % Plot result using standard Matlab triangular plotting routine
  H = trisurf(tn,xn,yn,hn,sn);

  % Make plot look nice
  shading interp
  axis tight
  set(gca,'DataAspectRatio',[1,1,1/20000],'clim',[0,1],'zlim',[-1,0.5])
  title(sprintf('%s (%s), color using %s (%s)\nstep %i (node values)',...
                items{1,1},items{1,3},items{4,1},items{4,3},i));
  view(-25,15);
  colorbar
  drawnow;
  pause(0.01);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot using mzPlot
% The difference between providing element values or node values to mzPlot
% corresponds to the difference in MikeZero between box contours and shaded
% contours. For element values each element will have one color. For node
% values, the color is interpolated within the element, giving smooth
% colors. mzPlot will give a 3D plot if both a z and a c (color) value is
% provided.
figure(3), clf, shg

i = nsteps-1;

% Load data
h = double(dfsu2.ReadItemTimeStep(1,i).Data)';
s = double(dfsu2.ReadItemTimeStep(4,i).Data)';

% Calculate node values of s and h
hn = mzCalcNodeValues(tn,xn,yn,h,xe,ye);
sn = mzCalcNodeValues(tn,xn,yn,s,xe,ye);

%% Color value
% element based values - box contours (raw color values)
subplot(2,2,1)
H = mzPlot(tn,xn,yn,h);
set(H,'EdgeAlpha',0);   % remove element lines
title(sprintf('%s - element based',items{1,1}));

% node based values - shaded contours (interpolated colors)
subplot(2,2,2)
H = mzPlot(tn,xn,yn,hn);
set(H,'EdgeAlpha',0);   % remove element lines
title(sprintf('%s - node based',items{1,1}));
           
%% "z" value and color value
% Note that "z" value must always be node based
            
% element based values - box contours (raw color values)
% z = h (node values), color = h (element values)
subplot(2,2,3)
H = mzPlot(tn,xn,yn,hn,h);
set(H,'EdgeAlpha',0);   % remove element lines
title(sprintf('%s',items{1,1}));
axis tight

% node based values - shaded contours (interpolated colors)
% z = h (node values), color = s (node values)
subplot(2,2,4)
H = mzPlot(tn,xn,yn,hn,sn);
set(H,'EdgeAlpha',0.2);   % remove element lines
set(gca,'clim',[0,1]);
title(sprintf('%s, color = %s',...
              items{1,1},items{4,1}));
axis tight


%%
dfsu2.Close();
