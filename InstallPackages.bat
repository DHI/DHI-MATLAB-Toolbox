IF NOT DEFINED nugetexe (SET nugetexe=c:\Programs\nuget.exe)
IF NOT DEFINED nugetopt (SET nugetopt=-Source "https://api.nuget.org/v3/index.json")
IF NOT DEFINED dhiver (SET dhiver=19.0.0)
IF NOT EXIST packages MKDIR packages

%nugetexe% install DHI.DFS -Version %dhiver% -OutputDirectory packages %nugetopt%
%nugetexe% install DHI.Projections -Version %dhiver% -OutputDirectory packages %nugetopt%
%nugetexe% install DHI.Mike1D.ResultDataAccess -Version %dhiver% -OutputDirectory packages %nugetopt%
