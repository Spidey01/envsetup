@ECHO OFF
IF NOT DEFINED PROJECT_ROOT (
	ECHO "PROJECT_ROOT not defined, please setup your environment"
	GOTO :eof
)


IF EXIST "%PROJECT_ROOT%\tmp\.m-uses-script" (
	cmake %* 1> "%PROJECT_ROOT%\tmp\cmake.log" 2>&1
	TYPE "%PROJECT_ROOT%\tmp\cmake.log"
) ELSE (
	cmake %* 
)

