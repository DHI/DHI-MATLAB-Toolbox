set csc=C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe
set sdkBin=..\mbin\windows
%csc% /t:library /out:MatlabDfsUtil.dll /r:"netstandard.dll" /r:"%sdkBin%\DHI.Generic.MikeZero.DFS.dll" /r:"%sdkBin%\DHI.Generic.MikeZero.EUM.dll" MatlabDfsUtil.cs
pause