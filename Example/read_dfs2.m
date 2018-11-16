% Example of reading and plotting a dfs2 file in an animation. It plots the
% water depth, and colors the mesh based on the current speed.

%% For Mike software release 2017 or older, comment the following three lines:
NET.addAssembly('DHI.Mike.Install');
import DHI.Mike.Install.*;
MikeImport.Setup(MikeMajorVersion.V17, [])

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;

infile = 'data/data_corner.dfs2';

if (~exist(infile,'file'))
  [filename,filepath] = uigetfile('*.dfs2','Select the .dfs2');
  infile = [filepath,filename];
end

dfs2 = DfsFileFactory.Dfs2FileOpen(infile);

% Read coordinates from file. Note that values are element center values
% and therefor 0.5*Dx/y is added to all coordinates
saxis = dfs2.SpatialAxis;
x = saxis.X0 + saxis.Dx*(0.5+(0:(saxis.XCount-1)))';
y = saxis.Y0 + saxis.Dy*(0.5+(0:(saxis.YCount-1)))';

itemname = char(dfs2.ItemInfo.Item(0).Name);
itemunit = char(dfs2.ItemInfo.Item(0).Quantity.UnitAbbreviation);
nsteps   = dfs2.FileInfo.TimeAxis.NumberOfTimeSteps;

deleteval = double(dfs2.FileInfo.DeleteValueFloat);

clf, shg
for i=0:nsteps-1

  % Read data for timestep
  h = double(dfs2.ReadItemTimeStep(1,i).To2DArray()); 
  p = double(dfs2.ReadItemTimeStep(2,i).To2DArray());
  q = double(dfs2.ReadItemTimeStep(3,i).To2DArray());

  % Remove delete values from plot (specific for this file!),
  % set them to NaN, since NaN's do not show up on the plots
  I = find(h == deleteval);
  h(I) = NaN;
  p(I) = NaN;
  q(I) = NaN;
  
  % Calculate current speed
  s = sqrt((p./h).^2+(q./h).^2);

  % Plot water depth, color surface with current speed. Transpose to
  % match Matlabs plotting routines
   mesh(x,y,h',s');
 
%   % Make plot look nice
   shading interp
%   colorbar
   zlim([19.8,20.2]);
   xlabel('x');
   ylabel('y');
   title(sprintf('%s (%s)\nColored using current speed - step %i',itemname,itemunit,i));
   drawnow;
   pause(0.01)

end

dfs2.Close();