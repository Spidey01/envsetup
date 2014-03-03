@ECHO OFF

IF NOT DEFINED JAVA_HOME (
	IF DEFINED JAVA_HOME (
		SET "PATH=%JAVA_HOME%\bin;%PATH%"
	)
)

IF EXIST "%PROJECT_ROOT%\.cmd\java-environment.local.cmd" CALL "%PROJECT_ROOT%\.cmd\java-environment.local.cmd"

GOTO :eof
