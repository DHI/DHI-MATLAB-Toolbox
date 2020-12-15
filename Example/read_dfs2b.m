% Example of reading and plotting a dfs2 bathymetry file


NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
import DHI.Generic.MikeZero.DFS.*;

dfs2b = DfsFileFactory.Dfs2FileOpen('data/bathy_oresund_900.dfs2');

% Read coordinates from file. Note that values are element center values
% and therefor 0.5*Dx/y is added to all coordinates
saxis = dfs2b.SpatialAxis;
x = saxis.X0 + saxis.Dx*(0.5+(0:(saxis.XCount-1)))';
y = saxis.Y0 + saxis.Dy*(0.5+(0:(saxis.YCount-1)))';

itemname = char(dfs2b.ItemInfo.Item(0).Name);

% Read bathymetry data
data = double(dfs2b.ReadItemTimeStep(1,0).To2DArray()); 

% Plot data, transposed to match Matlabs plotting routines
clf, shg
surf(x,y,data');
view(2);
axis equal tight
shading interp
title(itemname)

dfs2b.Close()