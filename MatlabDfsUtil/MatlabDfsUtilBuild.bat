set csc=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe
set sdkBin=C:\Program Files (x86)\DHI\2020\MIKE SDK\bin
%csc% /t:library /out:MatlabDfsUtil.2020.dll /r:"netstandard.dll" /r:"%sdkBin%\DHI.Generic.MikeZero.DFS.dll" /r:"%sdkBin%\DHI.Generic.MikeZero.EUM.dll" MatlabDfsUtil.cs
pause