REM Make new Zip (non-recursively, do not add directory items, exclude the .MySCMServerInfo files)
zip -D DHIMatlabToolbox.zip Documentation\*.pdf 
zip -D DHIMatlabToolbox.zip Example\*.m Example\data\*.* -x 
zip -D DHIMatlabToolbox.zip mbin\*.* mbin\@DFS\*.* -x mbin\Windows\*.*
zip -D DHIMatlabToolbox.zip MatlabDfsUtil\*.* -x MatlabDfsUtil\MatlabDfsUtilBuildRel.bat 
pause