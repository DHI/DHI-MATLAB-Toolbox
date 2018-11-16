When a new version of MIKE Sofwater is released, to update the 
DHI MATLAB Toolbox, the following is required:

1 Make a new MatlabDfsUtil.20XX.dll
  - Go to the MatlabDfsUtil folder
  - Update the MatlabDfsUtilBuild.bat, change the mzVer to the new version.
  - Run the MatlabDfsUtilBuild.bat. That will create a new MatlabDfsUtil.20XX.dll
  - Copy the MatlabDfsUtil.20XX.dll to the mbin folder.
2 Update the NetAddDfsUtil.m
  - In the mbin folder, open the NetAddDfsUtil.m and add lines alike:
        case 17 % Release 2019
            DfsUtilAss = NETaddAssembly('MatlabDfsUtil.2019.dll');
    matching the number and file of the new version.
3 Update the mzMikeVersion.m - similar to step 2
4 Run the CreateZip.bat
  - That puts all required files in the new DHIMatlabToolbox.zip. 
  - Give it a name matching the data of creation, i.e. something like DHIMatlabToolbox_20180818.zip
