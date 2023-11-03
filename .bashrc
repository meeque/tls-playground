# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

# TLS Playground

# add TP script to path
tp_bin="$( dirname "$( realpath "$BASH_SOURCE" )" )/bin"
if [[ -d "$tp_bin" && -x "$tp_bin/tp" && ":$PATH:" != *":$tp_bin:"* ]]
then
    PATH="$tp_bin:$PATH"
fi
unset tp_bin

# set up a minimalist TP prompt
if [[ -v TP_COLOR ]]
then
    tp_color="$TP_COLOR"
else
    case "$TERM" in
        xterm-color | *-256color )
            tp_color='yes';;
        * )
            tp_color='';;
    esac
fi
if [[ -n "$tp_color" ]]
then
    PS1='\[\e[1;44m\][TP]\[\e[0m\]\[\e[1;34m\]▶ \[\e[0m\]\$ '
else
    PS1='[TP] \$ '
fi
unset tp_color
