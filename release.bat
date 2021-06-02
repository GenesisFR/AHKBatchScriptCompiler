@echo off

rem Source: https://stackoverflow.com/a/11054984

set _ALL_ARGS=
set _ARCHIVE_NAME="release.zip"

rem No arguments
if ""%1""=="""" goto usage

rem Dequote the first argument
set _ARG=%1
call :dequote %_ARG%

rem And surround it with simple quotes
set _ALL_ARGS='%_ARG%'

shift

:parseArgs
rem All arguments have been parsed
if ""%1""=="""" goto compress

rem Dequote the current argument
set _ARG=%1
call :dequote %_ARG%

rem Add a comma separator and add the current argument surrounded by simple quotes
set _ALL_ARGS=%_ALL_ARGS%, '%_ARG%'

rem Replace the current argument by the next one
shift
goto parseArgs

:compress
rem https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.archive/compress-archive
powershell -Command Compress-Archive -Path %_ALL_ARGS% -Force -DestinationPath %_ARCHIVE_NAME%
EXIT /B %ERRORLEVEL% 

:usage
echo Incorrect usage, you must pass parameters.
pause
EXIT /B %ERRORLEVEL% 

rem This is a function that takes a single parameter
:dequote
setlocal
set _PARAM=%~1

rem Remove outer quotes (https://ss64.com/nt/syntax-dequote.html)
set _PARAM=###%_PARAM%###
set _PARAM=%_PARAM:"###=%
set _PARAM=%_PARAM:###"=%
set _PARAM=%_PARAM:###=%

rem Simple quotes need to be doubled
set _PARAM=%_PARAM:'=''%

rem Tunnels the result (https://ss64.com/nt/syntax-functions.html)
endlocal & set _ARG=%_PARAM%

rem Return where the function was called
EXIT /B