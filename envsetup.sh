
# in honor of Android.
hmm() { # This help.
    echo 'usage: ". ./envsetup.sh" from your shell to add the following functions to your environment'
    echo

    # Supported OS'es include the path here, so >_>.
    # Also this skips funcs with !a-z names (e.g. for internals).
    # It also skips undocumented.
    cat `gettop`/envsetup.sh | grep '^[a-z]*() {' | \
        sed -e 's/() { # /\t/' -e 's/[a-z]*() {.*$//' -e '/^$/d' -e 's/^/\t/' #| sort

    echo
    echo "Read the source for further details."
}


guess_is_top() {
    [ \
        -f "gradlew" \
        -a -f "build.gradle" \
        -a -f "settings.gradle" \
        -a -f "gradle/wrapper/gradle-wrapper.properties" \
        -a -d "core" \
        -a -d "android" \
        -a -d "pc" \
    ]
}


guess_is_project() {
    [ -f "build.gradle" ]
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
    local here dir parent targets task tasks
    for dir in `find ${@:-.} -name .git -prune -o -type f -name build.gradle`; do
        # echo debug dir=$dir dirname dir=`dirname $dir`
        here="`dirname $dir | sed -e 's/build.gradle//' -e 's/^\.\///' -e 's/\//:/g'`"
        # echo "here: $here"
        # skip .
        [ "$here" = '.' ] && continue

        parent="$(pwd | sed -e 's:'"$(gettop)"'::' -e 's/\//:/g')"
        # echo "parent: $parent"

        # skip if not in settings.gradle file.
        grep include "$(gettop)/settings.gradle" | grep -q "$parent:$here" || continue
        echo "$parent:$here"
    done
}


m() { # Makes from the top of the tree.
    cpushd > /dev/null
    [ -f "$(gettop)/tmp/.m-clears-screen" ] && clear

    if [ -f "$(gettop)/tmp/.m-uses-script" ] && type script >/dev/null; then
        script -c "\"$(gettop)/gradlew\" --daemon \"${@:-build}\"" "$(gettop)/tmp/gradlew.log"
    else
        "$(gettop)/gradlew" --daemon "${@:-build}"
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


mma() { # Builds all of the modules in the current directory, and their dependencies.
    local task project targets

    for project in `lsproj`; do
        for task in ${@:-build}; do
            targets="$targets $project:$task"
        done
    done
    m $targets

}


# mmma() { # Builds all of the modules in the supplied directories, and their dependencies.
# }


rd() { # :run a demo by name
    m ":demos:${1}:pc:run"
    # TODO: pass args to app as a property?
}


rdemo() { # alias for rd
    rd $*
}


idemo() { # :installApp a demo by name
    m ":demos:${1}:pc:installApp"
}


irdemo() { # installdemo and execute a demo by name with following args.
    local demo
    demo=$1
    shift
    idemo $demo
    eval \
        env \
            XDG_DATA_DIRS="`gettop`/demos/$demo/pc/src/dist/share" \
            XDG_CONFIG_DIRS="`gettop`/demos/$demo/pc/src/dist/etc" \
            XDG_DATA_HOME="`gettop`/tmp/share" \
            XDG_CONFIG_HOME="`gettop`/tmp/config" \
            XDG_CACHE_HOME="`gettop`/tmp/cache" \
            "`echo $demo | awk '{print toupper($0)}'`_PC_OPTS=\"'-Djava.library.path=$(gettop)/demos/${demo}/pc/build/install/${demo}-pc/lib/natives'\"" \
            \
                "$(gettop)/demos/${demo}/pc/build/install/${demo}-pc/bin/${demo}-pc" "$@"
}


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


choosejdk() {
    local option

    echo "Select a JDK:"
    select option in `ls /usr/lib/jvm`; do
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


_sxe_complete_projects() { ## bash completion function for project names.
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


_sxe_complete_demos() { ## bash completion function for demo names.
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="$(ls $(gettop)/demos | sed -e 's/\///')"

    COMPREPLY=($(compgen -W "$opts" -- ${cur}))  

    return 0

}


# complete project names for these commands.
complete -o nospace -F _sxe_complete_projects gradlew ./gradlew m mma

# complete demo names for these commands.
complete -F _sxe_complete_demos rd rdemo idemo irdemo

check_android

[ -f "$(gettop)/envsetup.local.sh" ] && . "$(gettop)/envsetup.local.sh"

