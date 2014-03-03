@ECHO OFF
IF NOT DEFINED SXE_ROOT (
	ECHO "SXE_ROOT not defined, please setup your environment"
	GOTO :eof
)

IF "%1" == "" (
	echo Select demo, e.g. .\%0 helloworld
	goto :eof
)
CALL "%SXE_ROOT%\.cmd\m.cmd" ":demos:%1:pc:installApp"

