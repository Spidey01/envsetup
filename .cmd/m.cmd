@ECHO OFF
IF NOT DEFINED PROJECT_ROOT (
	ECHO "PROJECT_ROOT not defined, please setup your environment"
	GOTO :eof
)
PUSHD "%PROJECT_ROOT%"

IF EXIST "%PROJECT_ROOT%\tmp\.m-clears-screen" CLS

IF EXIST Makefile (
	CALL m_make %*
) ELSE (
	IF EXIST build.ninja (
		CALL m_ninja %*
	) ELSE (
		IF EXIST build.gradle (
			CALL m_gradle %*
		) ELSE (
			IF EXIST CMakeLists.txt (
				m_cmake %*
			) ELSE (
				IF EXIST premake.lua (
					m_premake %*
				) ELSE (
					ECHO Don't know how to build this kind of project.
					GOTO :fixup
				)
			)
		)
	)
)

:fixup
POPD
