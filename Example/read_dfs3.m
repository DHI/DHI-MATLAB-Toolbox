% Example of reading and plotting a dfs3 file, plotting a number of 2D
% slices on top of each other. 

% %For MIKE software release 2019 or 2020, the following is required to find the MIKE installation files
% dmi = NET.addAssembly('DHI.Mike.Install');
% if (~isempty(dmi)) 
%   DHI.Mike.Install.MikeImport.SetupLatest({DHI.Mike.Install.MikeProducts.MikeCore});
% end

NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
import DHI.Generic.MikeZero.DFS.*;

% Open file
dfs3  = DfsFileFactory.Dfs3FileOpen('data/data_oresund_initsalt900.dfs3');

% Read coordinates from file. Note that values are element center values
% and therefor 0.5*Dx/y/z is added to all coordinates
saxis = dfs3.SpatialAxis;
x = saxis.X0 + saxis.Dx*(0.5+(0:(saxis.XCount-1)))';
y = saxis.Y0 + saxis.Dy*(0.5+(0:(saxis.YCount-1)))';
z = saxis.Z0 + saxis.Dz*(0.5+(0:(saxis.ZCount-1)))';
zsize = saxis.ZCount;

% Read first timestep
data = double(dfs3.ReadItemTimeStep(1,0).To3DArray()); 

% Plot a kind of layer plot of layer 21:5:41
% Scaling of z values to get plot look nice (otherwise remove axis equal)
clf, shg
hold on;
for il = 21:5:zsize
  % must be transposed to match Matlab plotting routines
  pdata = data(:,:,il)';
  surf(x,y,double(4000*(il-zsize)) + 0*pdata,pdata);
end
hold off;
axis equal tight
zlim([-85000 5000])
view(-15,10)
title(sprintf('%s - Layer 21:5:41 in dfs3 file',char(dfs3.ItemInfo.Item(0).Name)));
shading interp
drawnow;

dfs3.Close();
