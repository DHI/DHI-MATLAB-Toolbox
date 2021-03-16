# DHI MATLAB Toolbox
The **DHI MATLAB Toolbox** provides a number of tools and examples for working with 
DHI related data files within [MATLAB](https://www.mathworks.com/products/matlab.html). 

The current version of the toolbox supports reading of all dfs file types, dfs0+1+2+3+u. 
It also supports reading network results, such as results from MIKE 1D, MIKE 11 or MIKE URBAN/MOUSE/MIKE+ 
(files with extensions .res11, .res1d, .prf, .xrf, .trf, .crf). 

#### Content of this page
- How to get help
- Why a MATLAB Toolbox
- Download and installation
- Requirements
- Building a new releases of DHI MATLAB Toolbox
- Release notes

## How to get help
This pages includes an introduction on how to get started, and a few things to be aware of. 
- Questions, ideas and suggestions for new features: [GitHub Discussions](https://github.com/DHI/DHI-MATLAB-Toolbox/discussions)
- Bugs: [GitHub Issues](https://github.com/DHI/DHI-MATLAB-Toolbox/issues)


## Why a MATLAB TOOLBOX?

MATLAB provides a compact high-level technical programming/scripting language, and together 
with the DHI MATLAB Toolbox, it allows swift handling of time series data, analysis, 
visualisation and presentation. The MATLAB environment is very much hands-on and can 
be used without special programming skills for custom analysis of results from numerical models.

## Download and installation
Check out the Requirements section below.

Download the DHI MATLAB Toolbox: [DHI MATLAB Toolbox Releases download](https://github.com/DHI/DHI-MATLAB-Toolbox/releases).

Get the DHIMatlabToolbox_XXXX.zip, where XXXX represents the version number. Unzip its content. 
Assuming you unzip to the folder ``` C:\Matlab ```, then a folder called ``` C:\Matlab\mbin ```
should be created, including a lot files and a couple of subfolders. 
Note that the C:\Matlab folder can be replaced with any other folder, according to user preferences; just replace it in the following.

The ```C:\Matlab\mbin``` folder and subfolders should be added to the MATLAB search path. Start MATLAB, in the MATLAB command window, issue the command:

```
>> addpath(genpath('C:\Matlab\mbin'));
```

This will add recursively the folder to the MATLAB path for this MATLAB session only. 
To add the folder permanently to the path, instead add the command to your startup.m file, 
or use the menu ‘file’ - ‘Set Path’ and add the needed folders there. 
Two folders are required to be in the MATLAB serach path, the ```\mbin``` and the ```\mbin\windows``` folder.

You should now be ready to use the DHI MATLAB Toolbox.


## Requirements

The DHI MATLAB toolbox works on Windows only.

#### MATLAB
MATLAB must be installed. 

Only the 64 bit version of MATLAB will work with the latest version of the DHI MATLAB Toolbox. 
Prior to Mike Release 2017, also a 32 bit version is available. 

The current version of the toolbox has been tested on MATLAB R2018b, but earlier versions may also work. 
To read and write DFS files, MATLAB must be able to interact with .NET objects, which was introduced in MATLAB R2012b. 

#### MIKE Software
The current version of the DHI MATLAB toolbox does not require any MIKE Software to be installed. 
The toolbox contains all software required to work with DFS files. 

#### Microsoft Visual C++ redistributables
The MIKE software native components (DFS, EUM, Projections and others) require the 
“Microsoft Visual C++ redistributable” for Visual Studio 2017 or later in order to run.

These redistributables are often already installed. They are installed automatically 
when installing MIKE Zero, MIKE+, MIKE Urban or MIKE SDK. 
In case they are not already installed, they can be downloaded and installed from:

https://support.microsoft.com/en-us/help/2977003/the-latest-supported-visual-c-downloads


## Building a new releases of DHI MATLAB Toolbox
The DHI MATLAB Toolbox utilizes the [MIKE Core NuGet packages](https://www.nuget.org/packages/DHI.MikeCore/).
To build a new version of the toolbox run first:

1. Download the ```nuget.exe``` from https://www.nuget.org/downloads, store it in ```c:\Programs\nuget.exe```,
   or update the ```InstallPackages.bat``` to match the location of the ```nuget.exe``` file.
1. Run the ```InstallPackages.bat```: It will download the required NuGet packages to a ```packages``` folder.
2. Run the ```BuildBin.bat```: It will copy required content from the ```packages``` folder to the ```mbin\windows``` folder.
3. Make a new MatlabDfsUtil.dll
   - Go to the MatlabDfsUtil folder
   - Run the MatlabDfsUtilBuild.bat. That will create a new MatlabDfsUtil.dll
   - Copy the MatlabDfsUtil.dll to the mbin folder.
4. Run the ```CreateZip.bat```
   - That puts all required files in the new DHIMatlabToolbox.zip. 
   - Give it a name matching the version and data of creation, i.e. something like DHIMatlabToolbox_v19.0.0-20201217.zip


## Release notes
#### New in Version 19 (2021)
1: The toolbox now contains all software as part of the toolbox. It is no longer required to install 
any MIKE Software for the toolbox to work. Check section on Requirements for details.

2: The use of ```DHI.MIKE.Install``` to locate a MIKE installation is no longer required, and should be removed. 

3: To locate the required assemblies, the most convenient is to use the method: 

```
NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
```

Note that now the file extension ```'.dll'``` is also included,
which was not the case in previous versions of the toolbox. 
The following lines are the most common lines required in order to work with  dfs files

```
NETaddAssembly('DHI.Generic.MikeZero.DFS.dll');
NETaddAssembly('DHI.Generic.MikeZero.EUM.dll');
import DHI.Generic.MikeZero.DFS.*;
import DHI.Generic.MikeZero.*.*;
```

4: The dfsTSO class has been removed from version 19 (2021) of the DHI MATLAB toolbox, 
since the underlying TSObject is no longer a part of the MIKE software suite. 
To continue using the dfsTSO class and its functionality, download instead 
the version 18 (Release 2020) or earlier of the toolbox. 
Check out the user guide in that release zip file for details of using and installing the toolbox.
