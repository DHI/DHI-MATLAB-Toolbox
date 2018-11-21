# DHI MATLAB Toolbox
The **DHI MATLAB Toolbox** provides a number of tools and examples for working with 
DHI related data files within [MATLAB](https://www.mathworks.com/products/matlab.html). 
The DHI MATLAB Toolbox works with MIKE by DHI version 2012, 2014, 2016, 2017 and 2019. 
The Toolbox has been smoke-tested for MIKE version 2019 and MATLAB version 2016b.

The current version of the toolbox supports reading of all dfs file types, dfs0+1+2+3+u. 
From MIKE version 2017 it also supports reading network results, such as results from 
MIKE 11, MIKE 1D or MIKE URBAN/MOUSE (files with extensions .res11, .res1d, .prf, .xrf, .trf, .crf). 
Reading of network result files requires that MIKE 1D is installed, which is included 
when installing MIKE Zero with MIKE 11/MIKE HYDRO or MIKE URBAN.

## Download
[DHI MATLAB Toolbox Releases download](https://github.com/DHI/DHI-MATLAB-Toolbox/releases).

## Why a MATLAB TOOLBOX?

MATLAB provides a compact high-level technical programming/scripting language, and together 
with the DHI MATLAB Toolbox, it allows swift handling of time series data, analysis, 
visualisation and presentation. The MATLAB environment is very much hands-on and can 
be used without special programming skills for custom analysis of results from numerical models.

## Prerequisites

The DHI MATLAB Toolbox uses the MIKE Core components for reading dfs files. 
The MIKE Core components are installed by the MIKE SDK (Software Development Kit), 
MIKE Zero and MIKE URBAN products. If MIKE Zero or MIKE URBAN is not already installed 
(>1 GB download), just install the MIKE SDK (~50 MB). The MIKE SDK does not require any licence. 

[MIKE software Downloads](https://www.mikepoweredbydhi.com/).

## New releases of MIKE software

When a new version of MIKE Software is released, to update the DHI MATLAB Toolbox, the following is required:

1. Make a new MatlabDfsUtil.20XX.dll
   - Go to the MatlabDfsUtil folder
   - Update the MatlabDfsUtilBuild.bat, change the mzVer to the new version.
   - Run the MatlabDfsUtilBuild.bat. That will create a new MatlabDfsUtil.20XX.dll
   - Copy the MatlabDfsUtil.20XX.dll to the mbin folder.
2. Update the NetAddDfsUtil.m
   - In the mbin folder, open the NetAddDfsUtil.m and add lines matching the number and file of the new version, alike:
```
        case 17 % Release 2019
            DfsUtilAss = NETaddAssembly('MatlabDfsUtil.2019.dll');
```
3. Update the mzMikeVersion.m - similar to step 2
4. Run the CreateZip.bat
   - That puts all required files in the new DHIMatlabToolbox.zip. 
   - Give it a name matching the data of creation, i.e. something like DHIMatlabToolbox_20180818.zip
