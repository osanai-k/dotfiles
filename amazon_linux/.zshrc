setopt noautoremoveslash
setopt auto_list
setopt auto_menu
setopt list_packed

autoload -U compinit; compinit
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
				/usr/sbin /usr/bin /sbin /usr/bin
fpath=(~/.zsh/zsh-completions $fpath)

export HISTFILE=${HOME}/.zsh_history
export HISTSIZE=10000
export SAVEHIST=100000
setopt hist_ignore_dups
setopt share_history

autoload -U colors; colors
export LSCOLORS=Exfxcxdxbxegedabagacad
alias ls='ls --color=auto'
export CLICOLOR=true

autoload -Uz vcs_info
setopt prompt_subst
zstyle ':vcs_info:*' formats '(%F{green}%b%f)'
zstyle ':vcs_info:*' actionformats '(%F{green}%b%f(%F{red}%a%f))'

common_precmd() {
    vcs_info
    PROMPT='%U%M%#%u '
    RPROMPT='%F{green}%~%f${vcs_info_msg_0_}'
}

case "${TERM}" in
    screen*)
        preexec() {
            echo -ne "\ek${1:0:10}\e\\"
            #mycmd=(${(s: :)${1}})
            #echo -ne "\ek$(hostname|awk 'BEGIN{FS="."}{print $1}'):$mycmd[1]\e\\"
        }
        precmd() {
            echo -ne "\ek$(basename $SHELL)\e\\"
            common_precmd
            #echo -ne "\ek$(hostname|awk 'BEGIN{FS="."}{print $1}'):idle\e\\"
        }
        ;;
    *)
        precmd() { common_precmd }
        ;;
esac

##

alias sudo='sudo '
alias tomcat_start=$TOMCAT_HOME/bin/startup.sh
alias tomcat_stop=$TOMCAT_HOME/bin/shutdown.sh

export MAVEN_OPTS="-Xmx1g -XX:MaxPermSize=512m -Xverify:none -XX:+UseCompressedOops -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

alias less='less --tab=4'

prepath() {
    if [ ! -d "$1" ]; then
        echo 1>&2 "$1 is not a directory."
        return 1
    fi
    dir=$(cd $1; /bin/pwd)
    if echo ":$PATH:" | grep -q ":$dir:"; then
        :
    else
        PATH="$dir:$PATH"
    fi
}

preghc() {
    local binpath
    for i in /usr/local/ghc/ghc-$1*/bin/ghc; do
        if ! [ -x $i ]; then
            echo 1>&2 "Not found or not executable: $i"
            return 1
        fi
        local dir=$(dirname $i)
        echo $dir | grep HEAD >/dev/null 2>&1
        if [ $? -eq 0 ] && [ -z "$1" ]; then
            continue
        fi
        binpath="$dir"
    done
    els=""
    for el in $(echo "$PATH" | sed -e 's/:/ /g'); do
        case "$el" in
            *ghc*) : ;;
            *) els="$els $el";;
        esac
    done
    PATH=$(echo $els | sed -e 's/ /:/g' | sed -e 's/^://')
    echo 1>&2 $(dirname $binpath)
    prepath $binpath
}

