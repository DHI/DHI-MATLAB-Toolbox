The DHI MATLAB Toolbox provides a number of tools and examples for working with DHI related data files. The DHI MATLAB Toolbox works with MATLAB version 2018b.

WHY A MATLAB TOOLBOX?

MATLAB provides a compact high-level technical programming/scripting language, and together with the DHI MATLAB Toolbox, it allows swift handling of time series data, analysis, visualisation and presentation. The MATLAB environment is very much hands-on and can be used without special programming skills for custom analysis of results from numerical models.

From Version 19, The DHI MATLAB Toolbox does not require a MIKE installation to work. It contains all binaries for reading dfs files. 

The current version of the toolbox supports reading of all dfs file types, dfs0+1+2+3+u. From MIKE version 2017 it also supports reading network results, such as results from MIKE 11, MIKE 1D or MIKE URBAN/MOUSE (files with extensions .res11, .res1d, .prf, .xrf, .trf, .crf). 
Reading of network result files requires that MIKE 1D is installed, which is included when installing MIKE Zero with MIKE 11/MIKE HYDRO or MIKE URBAN PLUS. You just need to copy over the required dll from the Mike Installation into the Matlab Toolbox bin folder.


When a new version of MIKE Software is released, to update the DHI MATLAB Toolbox, the following is required:

1 Make a new MatlabDfsUtil.dll
  - Go to the MatlabDfsUtil folder
  - Update the MatlabDfsUtilBuild.bat, change the mzVer to the new version.
  - Run the MatlabDfsUtilBuild.bat. That will create a new MatlabDfsUtil.dll
  - Copy the MatlabDfsUtil.dll to the mbin folder.
2 Update the mzMikeVersion.m - similar to step 2
  - In the mbin folder, open the mzMikeVersion.m and add lines alike:
        case 19 % Release 2021
            mzVer = 2021;
3 Run the CreateZip.bat
  - That puts all required files in the new DHIMatlabToolbox.zip. 
  - Give it a name matching the data of creation, i.e. something like DHIMatlabToolbox_20211214.zip
