@ECHO OFF
CALL "%SXE_ROOT%\.cmd\idemo.cmd" %1
IF ERRORLEVEL 1 GOTO :eof
SETLOCAL
SET "XDG_DATA_DIRS=%SXE_ROOT%\%1\pc\src\dist\share"
SET "XDG_CONFIG_DIRS=%SXE_ROOT%\demos\%1\pc\src\dist\share"
REM problem: how to go from %1 (helloworld) to HELLOWORLD_PC_OPTS?
REM SET ...._PC_OPTS=-Djava.library.path=%SXE_ROOT%\demos\%1\pc\build\install\%1-pc\lib\natives

CALL "%SXE_ROOT%\demos\%1\pc\build\install\%1-pc\bin\%1-pc" %2 %3 %4 %5 %6 %7 %8 %9
ENDLOCAL
