@ECHO OFF

IF NOT DEFINED ANDROID_HOME (
	IF EXIST "%LocalAppData%\Android\android-sdk" (
		SET "ANDROID_HOME=%LocalAppData%\Android\android-sdk"
	) ELSE (
		IF EXIST "%ProgramFiles(x86)%\Android\android-sdk" (
			SET "ANDROID_HOME=%ProgramFiles(x86)%\Android\android-sdk"
		) ELSE (
			IF EXIST "%ProgramFiles(x86)%\Android\android-studio\sdk" (
				SET "ANDROID_HOME=%ProgramFiles(x86)%\Android\android-studio\sdk"
			)
		)
	)
	IF DEFINED ANDROID_HOME (
		SET "PATH=%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools;%PATH%"
	)
)

IF EXIST "%SXE_ROOT%\.cmd\android-environment.local.cmd" CALL "%SXE_ROOT%\.cmd\android-environment.local.cmd"

GOTO :eof
