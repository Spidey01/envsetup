@ECHO OFF
REM  This is free and unencumbered software released into the public domain.
REM 
REM  Anyone is free to copy, modify, publish, use, compile, sell, or
REM  distribute this software, either in source code form or as a compiled
REM  binary, for any purpose, commercial or non-commercial, and by any
REM  means.
REM 
REM  In jurisdictions that recognize copyright laws, the author or authors
REM  of this software dedicate any and all copyright interest in the
REM  software to the public domain. We make this dedication for the benefit
REM  of the public at large and to the detriment of our heirs and
REM  successors. We intend this dedication to be an overt act of
REM  relinquishment in perpetuity of all present and future rights to this
REM  software under copyright law.
REM 
REM  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
REM  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
REM  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
REM  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
REM  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
REM  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
REM  OTHER DEALINGS IN THE SOFTWARE.
REM 
REM  For more information, please refer to <http://unlicense.org>

SET "ENVSETUP_VERSION=1.1"

SET PROJECT_ROOT=%~dp0

CALL "%PROJECT_ROOT%\.cmd\java-environment.cmd"
IF NOT DEFINED JAVA_HOME (
	ECHO JAVA_HOME is not set!
	GOTO :eof
)

CALL "%PROJECT_ROOT%\.cmd\android-environment.cmd"
IF NOT DEFINED ANDROID_HOME (
	ECHO ANDROID_HOME is not set!
	GOTO :eof
)

SET "XDG_DATA_HOME=%PROJECT_ROOT%\tmp\share"
SET "XDG_CONFIG_HOME=%PROJECT_ROOT%\tmp\config"
SET "XDG_CACHE_HOME=%PROJECT_ROOT%\tmp\cache"
SET "PATH=%PROJECT_ROOT%\.cmd;%PATH%"

IF EXIST "%PROJECT_ROOT%\envsetup.local.cmd" CALL "%PROJECT_ROOT%\envsetup.local.cmd"

