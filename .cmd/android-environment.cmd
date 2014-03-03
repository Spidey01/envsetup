@ECHO OFF

IF NOT DEFINED ANDROID_HOME (
	REM normal place for "Just for me" SDK installs.
	IF EXIST "%LocalAppData%\Android\android-sdk" (
		SET "ANDROID_HOME=%LocalAppData%\Android\android-sdk"
	) ELSE (
		REM normal place for global SDK installs.
		IF EXIST "%ProgramFiles(x86)%\Android\android-sdk" (
			SET "ANDROID_HOME=%ProgramFiles(x86)%\Android\android-sdk"
		) ELSE (
			REM normal place for Android Studio installs.
			IF EXIST "%ProgramFiles(x86)%\Android\android-studio\sdk" (
				SET "ANDROID_HOME=%ProgramFiles(x86)%\Android\android-studio\sdk"
			)
		)
	)
	REM make sure Path is set correctly.
	IF DEFINED ANDROID_HOME (
		SET "PATH=%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\tools;%PATH%"
	)
)

REM allow a local version of us to continue with setup.
IF EXIST "%PROJECT_ROOT%\.cmd\android-environment.local.cmd" CALL "%PROJECT_ROOT%\.cmd\android-environment.local.cmd"

GOTO :eof
