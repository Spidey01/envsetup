@ECHO OFF
IF NOT DEFINED PROJECT_ROOT (
	ECHO "PROJECT_ROOT not defined, please setup your environment"
	GOTO :eof
)
PUSHD "%PROJECT_ROOT%"

IF EXIST "%PROJECT_ROOT%\tmp\.m-clears-screen" CLS

IF EXIST "%PROJECT_ROOT%\tmp\.m-uses-script" (
	@CALL "%PROJECT_ROOT%\gradlew.bat" --daemon %* 1> .\tmp\gradlew.log 2>&1
) ELSE (
	@CALL "%PROJECT_ROOT%\gradlew.bat" --daemon %* 
)

POPD
