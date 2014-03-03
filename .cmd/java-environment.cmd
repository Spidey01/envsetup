@ECHO OFF

IF NOT DEFINED JAVA_HOME (
	IF DEFINED JAVA_HOME (
		SET "PATH=%JAVA_HOME%\bin;%PATH%"
	)
)

IF EXIST "%SXE_ROOT%\.cmd\java-environment.local.cmd" CALL "%SXE_ROOT%\.cmd\java-environment.local.cmd"

GOTO :eof
