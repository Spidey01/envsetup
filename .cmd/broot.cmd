@ECHO OFF
IF NOT DEFINED PROJECT_BUILDDIR (
	ECHO "PROJECT_BUILDDIR not defined, please setup your environment"
	GOTO :eof
)

CD "%PROJECT_BUILDDIR%"

