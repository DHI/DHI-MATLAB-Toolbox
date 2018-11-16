This folder contains source code and build script for the 
MatlabDfsUtil library. 

With these files you can rebuild the MatlabDfsUtil.XXXX.dll
in case it fails. It also shows how to extend and add further
functionality to the MatlabDfsUtil, and it can also work as a 
template for building a complete other library.

There is a MatlabDfsUtilBuild.bat which will build a new version
of the MatlabDfsUtil.XXXX.dll. Please update the path of the 
csc.exe (Microsoft C# compiler) and the MIKE SDK installation 
folder, in case it does not match the currently defined ones.

For Release 2012 and 2011 the sdkBin variable should point to the
DHI Program Files bin folder, usually something like:
    "c:\Program Files (x86)\DHI\2012\bin"

