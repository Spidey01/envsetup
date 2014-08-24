@ECHO OFF
IF NOT DEFINED PROJECT_ROOT (
	ECHO "PROJECT_ROOT not defined, please setup your environment"
	GOTO :eof
)


IF EXIST "%PROJECT_ROOT%\tmp\.m-uses-script" (
	@CALL "%PROJECT_ROOT%\gradlew.bat" --daemon %* 1> "%PROJECT_ROOT%\tmp\gradlew.log" 2>&1
	TYPE "%PROJECT_ROOT%\tmp\gradlew.log"
) ELSE (
	@CALL "%PROJECT_ROOT%\gradlew.bat" --daemon %* 
)

