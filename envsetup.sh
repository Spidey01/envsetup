#-
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org>

ENVSETUP_VERSION="1.1"

# database like list of project files, see 'filelist'.
# path is relative to projet root.
#
ENVSETUP_FILELIST=tmp/filelist


# in honor of Android.
hmm() { # This help.
    echo 'usage: ". ./envsetup.sh" from your shell to add the following functions to your environment'
    echo

    # Supported OS'es include the path here, so >_>.
    # Also this skips funcs with !a-z names (e.g. for internals).
    # It also skips undocumented.
    cat `gettop`/envsetup.{sh,local.sh} | grep '^[a-z]*() {' | \
        sed -e 's/() { # /\t/' -e 's/[a-z]*() {.*$//' -e '/^$/d' -e 's/^/\t/' #| sort

    echo
    echo "Read the source for further details."
}


guess_is_top() {
    # These files are always present at top.
    if [ -f "envsetup.cmd" -a -f "envsetup.sh" ]; then return 0; fi
    if ! [ -f "COPYING" -a -f "README" ]; then return 127; fi

    # are we a gradle top?
    [ \
        -f "gradlew" \
        -a -f "build.gradle" \
        -a -f "settings.gradle" \
        -a -f "gradle/wrapper/gradle-wrapper.properties" \
    ] && return 0

    # are we a make top?
    [ \
        -f "Makefile" \
        -a -d "src" -a -d "include" \
    ] && return 0
}


guess_is_project() {
    [ -f "Makefile" -o \
      -f "build.gradle" -o \
      -f "build.xml" -o \
      -f "CMakeLists" -o \
      -f "premake.lua" \
    ]
}


is_system_root() {
    [ "`pwd`" == "/" ]
}


gettop() { # print path to top of the tree.
    local here

    here="`pwd`"
    while ! guess_is_top && ! is_system_root; do
        cd ..
    done
    ! is_system_root && pwd
    cd "$here"
}


croot() { # cd to top of the tree.
    cd "`gettop`"
}


cpushd() { # call pushd with the top of the tree.
    pushd "`gettop`"
}


mpushd() { # call pushd with a module name.
    pushd "`gettop`/`echo $1 | sed -e 's/:/\//g'`"
}


lsproj() { #
    local here dir parent project_file targets task tasks type
    for project_file in $(find ${@:-.} -name .git -prune \
        -o -type f -name build.gradle \
        -o -type f -name Makefile \
        -o -type f -name Makefile.am \
        )
    do
        dir="$(dirname "$project_file")"
        type="$(basename "$project_file")"
        # echo "debug dir=$dir project_file=$project_file type=$type"

        # skip .
        [ "$here" = '.' ] && continue
        
        case "$type" in
            build.gradle)
                # gradle uses a :module:name notaton. Modules come from settings.gradle.

                # our module name.
                here="`echo $dir | sed -e 's/^\.\///' -e 's/\//:/g'`"
                # echo "here=$here"

                # figure out what the parents of this project is.
                parent="$(pwd | sed -e 's:'"$(gettop)"'::' -e 's/\//:/g')"
                # echo "parent: $parent"

                # skip if not in settings.gradle file.
                grep include "$(gettop)/settings.gradle" | grep -q "$parent:$here" && echo "$parent:$here"
                ;;
            Makefile|Makefile.*)
                # assume it works this way.
                echo "$dir" | sed -e 's/^\.\///'
                ;;
            *)
                # not a project.
                ;;
        esac

    done
}


_maybe_use_script() { ## run it's args and log to tmp/build.log
    if [ -f "$(gettop)/tmp/.m-uses-script" ] && type script >/dev/null; then
        script -c "$*" "$(gettop)/tmp/build.log"
    else
        eval $*
    fi
}


m_gradle() { # runs gradle based build in cwd.
    _maybe_use_script "$(gettop)/gradlew" --daemon "${@:-build}"
}


m_make() { # runs make based build in cwd.
    _maybe_use_script make $*
}


m() { # Makes from the top of the tree. Selects m_tool correctly.
    cpushd > /dev/null
    if guess_is_project; then
        [ -f "$(gettop)/tmp/.m-clears-screen" ] && clear
        if [ -f Makefile ]; then
            m_make $*
        elif [ -f build.gradle ]; then
            m_gradle $*
        else
            echo "Don't know how to build this kind of project."
        fi
    fi
    popd
}


# This function is dirty and I can't seem to get gradle to NOT build dependencies so easily.
# And to be honest, I don't really care about this function..
#
# mm() { # Builds all of the modules in the current directory, but not their dependencies.
#     local task project targets projects_list excludes_list
# 
#     echo "broken"
#     return
# 
#     #### dirty hack! Gets the list of projects from settings.gradle. ####
#     projects_list="$(cat "$(gettop)/settings.gradle" | grep "^include" | cut -d\' -f2)"
#     # echo $projects_list
# 
#     excludes_list="$(for project in $(lsproj) $projects_list; do echo $project ; done | sort | uniq -u)"
#     # echo $excludes_list
# 
#     for project in $excludes_list; do
#         targets="$targets -x $project:build"
#     done
# 
#     for project in `lsproj`; do
#         for task in ${@:-build}; do
#             targets="$targets $project:$task"
#         done
#     done
# 
#     m --continue $targets
# 
# }


# mmm() { # Builds all of the modules in the supplied directories, but not their dependencies.
    # echo $@
# }


mma() { # Run m for all of the modules in the current directory.
    local task project targets

    for project in `lsproj`; do
        if echo "$project" | grep -q ':'
        then # gradle project.
            for task in ${@:-build}; do
                targets="$targets $project:$task"
            done
        elif [ -f "${project}/Makefile" ]; then
            targets="$targets $project-$1"
        fi
    done
    echo m $targets
}


# mmma() { # Builds all of the modules in the supplied directories, and their dependencies.
# }


jgrep() { # runs grep on all local Java source files.
    find . -name .git -prune -o -type f -name "*\.java" -print0 | xargs -0 grep --color -n "$@"
}


cgrep() { # runs grep on all local C/C++ source files.
    find . -name .git -prune -o -type f \
        \( -name '*\.c' -o -name '*\.cpp' -o -name '*\.cxx' -o -name '*\.cc' -o \
           -name '*\.h' -o -name '*\.hpp' -o -name '*\.hxx' -o -name '*\.hh' \) \
        -print0 | xargs -0 grep --color -n "$@"
}


resgrep() { #  runs grep on all local res/*.xml files.
    local dir
    for dir in `find . -name .git -prune -o -name res -type d`; do
        find $dir -type f -name '*\.xml' -print0 | xargs -0 grep --color -n "$@"
    done;
}


mangrep() { #  runs grep on all local AndroidManifest.xml files.
    find . -name .git -prune -o -type f -name 'AndroidManifest.xml' -print0 | xargs -0 grep --color -n "$@"
}


filelist() { # create index of project files.
    local project dirs p

    croot
    echo -n "Creating index..."


    dirs=""
    for project in $(lsproj); do
        # make sure any gradle projects are converted to paths.
        # first -e is for the leading :!
        p="$(echo "./$project" | sed -e 's/://' -e 's/:/\//g')"
        # echo "p=$p"
        dirs="$dirs $p"
    done

    # exclude what looks like a temporary or hidden directory.
    find $dirs -not \( \
        -type d -name \.\*  -prune -o \
        -type d -name tmp   -prune -o \
        -type d -name out   -prune -o \
        -type d -name build -prune -o \
        -type d -name obj   -prune \
    \) -type f | sort | uniq > "./$ENVSETUP_FILELIST"


    echo " Done"
    cd "$OLDPWD"
}


flgrep() { # grep against the filelist.
    grep "$@" "$(gettop)/$ENVSETUP_FILELIST"
}


godir() { # Go to the directory containing a file.
    local T db matches count

    T=$(gettop)
    db="$T/${ENVSETUP_FILELIST}"

    if [ ! -f "$db" ]; then
        filelist
    fi

    matches=($(grep $* "$db"))
    count=${#matches[@]}

    [ "$count" -eq 0 ] && return # not found
    [ "$count" -eq 1 ] && {
        mpushd "$(dirname "${matches[0]}")"
        return
    }

    echo "count $count"
    select which in "${matches[@]}"; do
        mpushd "$(dirname "$which")"
        return
    done
}


choosejdk() { # Export a JAVA_HOME.
    local option jdk where

    JDK_LIST=""

    for where in /usr/lib/jvm /usr/local/lib/jvm; do
        [ -d "$where" ] || continue
        for jdk in $(ls "$where"); do
            JDK_LIST="$JDK_LIST ${where}/${jdk}"
        done
    done

    echo "Select a JDK:"
    select option in $JDK_LIST; do
        export JAVA_HOME="$option"
        break
    done
}


check_android() { # fuzzy helper for ANDROID_HOME.
    local findArgs buildToolsVersion compileSdkVersion

    if [ -z "$ANDROID_HOME" ]; then
        echo 'ANDROID_HOME is not set!'
        return 1
    else
        findArgs=". -name .git -prune -o -name build.gradle -print0"
        
        # there should be a function for greping for build.gradle files!

        for buildToolsVersion in $(find $findArgs | xargs -0 grep buildToolsVersion | sed -e 's/.*buildToolsVersion "//' -e 's/"//' | sort | uniq); do

            [ ! -d "$ANDROID_HOME/build-tools/$buildToolsVersion" ] && echo "Android SDK missing build-tools/$buildToolsVersion"
        done

        # similar for 
        #   compileSdkVersion 10
        #   minSdkVersion 10
        #   targetSdkVersion 18
    fi

}


_envsetup_complete_projects() { ## bash completion function for project names.
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(lsproj)"

    # these commands allow us to complete on :words correctly when compgen'ing
    # with colons around.
    _get_comp_words_by_ref -n : cur
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))  
    __ltrim_colon_completions "$cur"

    return 0
}


# complete project names for these commands.
complete -o nospace -F _envsetup_complete_projects m mma m_make m_gradle

check_android

if [ -f "$(gettop)/envsetup.local.sh" ]; then
    . "$(gettop)/envsetup.local.sh"
else
    cat << EOF > "$(gettop)/envsetup.local.sh"
#
# Place local changes to envsetup.sh here.
# This includes environment variables, etc.
#

PROJECT_NAME="$(basename $(pwd))"

EOF
fi

