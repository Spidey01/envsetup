@ECHO OFF
IF NOT DEFINED PROJECT_ROOT (
	ECHO "PROJECT_ROOT not defined, please setup your environment"
	GOTO :eof
)

REM we were called with the path (or something).
IF "%1" NEQ "" (
	ECHO SET "ANDROID_HOME=%1"
	GOTO :eof
) ELSE (
        ECHO ANDROID_HOME is not set!
	GOTO :eof
)

REM Don't have a way to pick build-tools.
GOTO :eof

