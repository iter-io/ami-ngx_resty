#!/bin/bash

# local variables
export PATH=/bin:/sbin:/usr/sbin:/usr/bin:/usr/local/bin:$HOME/bin/bin
export LD_LIBRARY_PATH=/usr/local/lib:/usr/lib

export HOSTSHORT=`hostname`
export OS=`uname`;

export LC_ALL='en_US.UTF-8'
export LANG='en_US.UTF-8'

export EDITOR=vim
export PAGER=less

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
        shopt -s "$option" 2> /dev/null
done

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2 | tr ' ' '\n')" scp sftp ssh

export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
