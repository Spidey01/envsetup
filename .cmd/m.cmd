@ECHO OFF
IF NOT DEFINED SXE_ROOT (
	ECHO "SXE_ROOT not defined, please setup your environment"
	GOTO :eof
)
PUSHD "%SXE_ROOT%"

IF EXIST "%SXE_ROOT%\tmp\.m-clears-screen" CLS

IF EXIST "%SXE_ROOT%\tmp\.m-uses-script" (
	@CALL "%SXE_ROOT%\gradlew.bat" --daemon %* 1> .\tmp\gradlew.log 2>&1
) ELSE (
	@CALL "%SXE_ROOT%\gradlew.bat" --daemon %* 
)

POPD
