@ECHO OFF
IF NOT DEFINED SXE_ROOT (
	ECHO "SXE_ROOT not defined, please setup your environment"
	GOTO :eof
)

CD "%SXE_ROOT%"
