IF NOT EXIST mbin\windows MKDIR mbin\windows

for /d %%i in (packages\*) do ( 
  IF EXIST "%%i\runtimes\win-x64\native" (
    copy /y "%%i\runtimes\win-x64\native" mbin\windows))

for /d %%i in (packages\*) do ( 
  IF EXIST "%%i\lib\netstandard2.0" (
    copy /y "%%i\lib\netstandard2.0" mbin\windows))

rm mbin\windows\_._