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

ENVSETUP_VERSION="1.5.3"

# database like list of project files, see 'filelist'.
# path is relative to projet root.
#
ENVSETUP_FILELIST=tmp/filelist

# Path relative to `gettop` that contains envsetup.sh and related files.
# Default is "" or envsetup if present in PWD.
#
[ -z "$ENVSETUP_DIR" -a -d ./envsetup ] && ENVSETUP_DIR='envsetup'


# in honor of Android.
hmm() { # This help.
    local sources

    echo 'usage: ". ./envsetup.sh" from your shell to add the following functions to your environment'
    echo

    # Search these files:
    #
    #   - $ENVSETUP_DIR/envsetup.sh
    #   - envsetup.project.sh
    #   - envsetup.local.sh
    sources="`gettop`/${ENVSETUP_DIR}/envsetup.sh"
    [ -f "`gettop`/envsetup.project.sh" ] && sources="$sources `gettop`/envsetup.project.sh"
    [ -f "`gettop`/envsetup.local.sh" ] && sources="$sources `gettop`/envsetup.local.sh"

    #
    # Gets out comments like 'foo() { # Help message here...'
    # Also this skips funcs with !a-z names or ## comments (e.g. for internals).
    cat $sources | grep '^[a-z]*() {' | \
        sed -e 's/() { # /\t\t/' -e 's/[a-z]*() {.*$//' -e '/^$/d' -e 's/^/\t/' #| sort

    echo
    echo "Read the source for further details."
}


guess_is_top() {
    # These files are always present at top.
    if [ -f "${ENVSETUP_DIR}/envsetup.cmd" -a -f "${ENVSETUP_DIR}/envsetup.sh" ]; then return 0; fi
    # Need to be less draconian about this somehow.
    # if ! [ -f "COPYING" -a -f "README" ]; then return 127; fi

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
      -f "build.ninja" -o \
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

broot() { # cd to top of the build tree.
    if [ -z "$PROJECT_BUILDDIR" ]; then
        echo "PROJECT_BUILDDIR not defined, please setup your environment"
    fi
    cd "$PROJECT_BUILDDIR"
}


cpushd() { # call pushd with the top of the tree.
    pushd "`gettop`"
}


bpushd() { # call pushd with the top of the build tree.
    pushd "$PROJECT_BUILDDIR"
}


mpushd() { # call pushd with a module name.
    pushd "`gettop`/`echo $1 | sed -e 's/:/\//g'`"
}


lsproj() { # list projects.
    local here dir parent project_file targets task tasks type
    for project_file in $(find ${@:-.} -name .git -prune \
        -o -type f -name build.gradle \
        -o -type f -name Makefile \
        -o -type f -name Makefile.am \
        -o -type f -name build.ninja \
        -o -type f -name CMakeLists.txt \
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
            Makefile|Makefile.*|build.ninja)
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

m_ninja() { # runs ninja based build in cwd.
    _maybe_use_script ninja $*
}

m_cmake() { # runs cmake based build in cwd.
    _maybe_use_script cmake $*
}

m_premake() { # runs premake based build in cwd.
    _maybe_use_script premake $*
}

m() { # Makes from the top of the tree. Selects m_tool correctly.

    # If using cmake, may need to use a different dir than root.
    if [ -n "$PROJECT_BUILDDIR" -a -d "$PROJECT_BUILDDIR" -a -f CMakeLists.txt ]; then
        pushd "$PROJECT_BUILDDIR"
    else
        cpushd > /dev/null
    fi

    if guess_is_project; then
        [ -f "$(gettop)/tmp/.m-clears-screen" ] && clear
        if [ -f Makefile ]; then
            m_make $*
        elif [ -f build.ninja ]; then
            m_ninja $*
        elif [ -f build.gradle ]; then
            m_gradle $*
        elif [ -f CMakeLists.txt ]; then
            m_cmake $*
        elif [ -f premake.lua ]; then
            m_premake $*
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


search() { # search [-name find_pattern]... [grep args].
    local fargs gargs

    while [ $# -gt 0 ]; do
        case "$1" in
            -name)
                if [ -z "$fargs" ]; then
                    fargs="$1 $2"
                else
                    fargs="$fargs -o $1 $2"
                fi
                shift 2
                ;;
            *)
                gargs="$gargs $1"
                shift
            ;;
        esac
    done

    # no -name = any file.
    [ -z "$fargs" ] && fargs="-name \*"

    eval "find . -name .git -prune -o -type f \( ${fargs} \) -print0" \
        | eval "xargs -0 grep --color -n $gargs"
}


jgrep() { # runs grep on all local Java source files.
    search -name "*\.java" "$@"
}


cgrep() { # runs grep on all local C/C++ source files.
    search -name '*\.c' -name '*\.cpp' -name '*\.cxx' -name '*\.cc' \
           -name '*\.h' -name '*\.hpp' -name '*\.hxx' -name '*\.hh' \
            "$@"
}


resgrep() { # runs grep on all local res/*.xml files.
    local dir
    for dir in `find . -name .git -prune -o -name res -type d`; do
        find $dir -type f -name '*\.xml' -print0 | xargs -0 grep --color -n "$@"
    done;
}


mangrep() { # runs grep on all local AndroidManifest.xml files.
    search -name 'AndroidManifest.xml' "$@"
}


filelist() { # create index of project files.
    local project dirs p

    croot
    echo -n "Creating index..."

    # exclude hidden, dir names, project files.
    find . \
            \( -type d -path '*/\.*' -prune -o ! -name '.*' \) \
            ! \( \
                -type d -path '*/build' -prune -o \
                -type d -path '*/obj' -prune -o \
                -type d -path '*/out' -prune -o \
                -type d -path '*/tmp' -prune \
              \) \
            ! \( \
                -name Makefile.\* -o -name \*.mak -o \
                -name \*.ninja -o \
                -name \*.gradle -o \
                -name build.xml -o \
                -name CMakeLists.txt -o \
                -name premake.lua \
              \) \
            -type f -print \
        | sort | uniq > "./$ENVSETUP_FILELIST"

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


choose_android() { # fuzzy helper for ANDROID_HOME.
    local prefix version

    if [ $# -gt 0 ]; then
        ANDROID_HOME="$1"
        export ANDROID_HOME
    fi

    if [ -z "$ANDROID_HOME" ]; then
        echo 'ANDROID_HOME is not set!'
        return 1
    else
        prefix="${ANDROID_HOME}/build-tools"
        echo "Select build tools version in $prefix"
        select version in "$(ls "$prefix")"; do
            echo "PATH=${prefix}/${version}:\$PATH"
            # PATH="${prefix}/${version}:$PATH"
            return
        done
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
complete -o nospace -F _envsetup_complete_projects m mma m_make m_gradle m_ninja m_cmake m_premake


if [ -f "$(gettop)/envsetup.project.sh" ]; then
    . "$(gettop)/envsetup.project.sh"
fi


if [ -f "$(gettop)/envsetup.local.sh" ]; then
    . "$(gettop)/envsetup.local.sh"
else
    cat << EOF > "$(gettop)/envsetup.local.sh"
#
# Place local changes to envsetup.sh here.
# This includes environment variables, etc.
#

PROJECT_NAME="$(basename $(pwd))"

# Set this if you want to override where 
# E.g.:
#    PROJECT_BUILDDIR=build
#    m -S . -B build -G "CMake Generator" -> run cmake at root
#    m -> now run cmake from build
#

# PROJECT_BUILDDIR=

EOF
fi

