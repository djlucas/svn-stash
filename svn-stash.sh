svn-stash() {
    if [ "${#}" -ne "1" ]; then
        echo "Usage: svn-stash <STASH_NAME>"
    else
        svn diff > ".${1}.svnstash"
        svn patch --reverse-diff ".${1}.svnstash"
    fi
}

svn-stash-list() {
    ls -l .*.svnstash 2>&1>/dev/null
    if [ "${?}" -ne "0" ]; then
        echo "Sorry, no stashes at this level."
    else
        ls -l .*.svnstash | \
            awk '{print $9"\t"$6" "$7"\t"$8"\t"$5}' | \
            sed 's@^\.@@;s@\.svnstash@@'
    fi
}

svn-unstash() {
    if [ "${#}" -gt "2" -o "${#}" -lt "1" ]; then
        echo "Usage: svn-unstash [-d] <STASH_NAME>"
    fi
    if [ "${#}" == "2" ]; then
        if [ ! -f ".${2}.svnstash" ]; then
            echo "Error: No file named '.${2}.svnstash' found."
            echo "See output of svn-stash-list"
        elif [ "x${1}" != "x-d" ]; then
            echo "Usage: svn-unstash [-d] <STASH_NAME>"
        else
            svn patch ".${2}.svnstash" &&
            rm ".${2}.svnstash"
        fi
    else
        if [ ! -f ".${1}.svnstash" ]; then
            echo "Error: No file named '.${1}.svnstash' found."
            echo "See output of svn-stash-list"
        else
            svn patch ".${1}.svnstash"
        fi
    fi
}

svn-restash() {
    if [ "${#}" -ne "1" ]; then
        echo "Does not rediff, only patches with --reverse-diff:"
        echo "Usage: svn-restash <STASH_NAME>"
    fi
    if [ ! -f ".${1}.svnstash" ]; then
        echo "Error: No file named '.${1}.svnstash' found."
        echo "Usage: svn-restash <STASH_NAME>"
        echo "See output of svn-stash-list"
    else
        svn patch --reverse-diff ".${1}.svnstash"
    fi
}

_svn-unstash() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local list=$(svn-stash-list | awk '{print $1}')
    COMPREPLY=( $(compgen -W "$list" -- $cur) )
}
complete -F _svn-unstash svn-unstash
complete -F _svn-unstash svn-restash

export -f svn-stash svn-stash-list svn-unstash
