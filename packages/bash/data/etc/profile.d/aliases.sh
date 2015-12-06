#!/bin/bash

############
#  format  #
############
#alias name=value
#alias name='command'
#alias name='command arg1 arg2'
#alias name='/path/to/script'
#alias name='/path/to/script.pl arg1'
#unalias aliasname


# Shortcuts
alias g="git"
alias h="history"
alias v="vim"
alias vi="vim"
alias edit="vim"
alias grep="grep -rnE --color"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias mkdir="mkdir -pv"
alias cp='cp -v'
alias cpr='cp -r'
alias mv='mv -v'
alias chmod='chmod -v --preserve-root'
alias chown='chown -v --preserve-root'
alias chgrp='chgrp -v --preserve-root'
alias df="df -h"
alias du="du -h"
alias last="last -a"
alias free='free -m'
alias lftp="lftp user:pwd@ftpip"
alias diff='colordiff'
#alias ln='ln -s'
alias bc='bc -l'

#chdir
alias ..="cd .."
alias cdd="cd .."
alias cd..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias .4='cd ../../../../'
alias .5='cd ../../../../..'
alias -- -='cd -'

#short cut
alias s='sudo'   #sudo时
alias apt-get='sudo apt-get'
alias upgrade='sudo apt-get update && sudo apt-get upgrade'

alias gu='iconv -f gbk -t utf-8'
alias ug='iconv -f utf-8 -t gbk'
alias ssh='ssh -2'
alias ms='mysql -uroot -p123456'    #mysql

alias sv="sudo vim"
alias vd='vimdiff'
alias tf='tail -f'
alias t100='tail -n 100'
alias af="awk -F '\t' '{print NF}'"
alias wl='wc -l'
alias c="clear"
alias cls="clear"
alias dus="du -s"
alias du0="du --max-depth=0"
alias du1="du --max-depth=1"

#alias ll='ls -al --color=tty'
#alias lx='ls -lhBX --color=auto'        #sort by extension
#alias lz='ls -lhrS --color=auto'        #sort by size
#alias lt='ls -lhrt --color=auto'        #sort by date


alias lsd='find . -maxdepth 1 -type d | sort'
alias sl='ls'

export OS=`uname`
if [ $OS = "Linux" ]; then
    alias ls='ls --color -F'
else
    alias ls='ls -GF'
fi

alias pong='ping -c 5 '
alias ports='netstat -tulanp'
alias dfind='find -type d -name'
alias ffind='find -type f -name'
alias chux='chmod u+x'
alias psg='ps aux|grep'
alias meminfo='free -m -l -t'
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4'
## Get server cpu info ##
alias cpuinfo='lscpu'

alias md5='md5sum'

alias rmpyc='find . -name "*.pyc" -exec rm -rf {} \; >> /dev/null 2>&1'
alias now='date +"%Y-%m-%d %T"'

#svn operation
alias rmsvn='find . -name ".svn" -exec rm -rf {} \; >> /dev/null 2>&1'
alias svnci='svn ci -m "commit by $USER" '
alias svnst='svn st'

#for go
alias gor='go run'
alias gob='go build'

#for nginx
alias nginx='/etc/init.d/nginx'

#for redis
alias redis='/etc/init.d/redis_6379'
alias rediscli='redis-cli'

#get myip
alias myip='curl ifconfig.me'

#for tmux
alias tm='tmux -2'
alias tma='tmux -2 attach'

#for admins
alias lusers='cat /etc/passwd | cut -d: -f1'

#my own script
alias bk="~/bin/back_up.py -i"    #use my backup script to backup a file/dir

#for bash env file
alias reload='source ~/.bashrc'
alias bashrc='vim ~/.bashrc && source ~/.bashrc'
alias bashpr='vim ~/.bash_profile && source ~/.bash_profile'
alias vh='sudo vim /etc/hosts'

calc()
{
   echo "$*" | bc
}

extract(){
if [ -f $1 ]; then
         case $1 in
             *.tar.bz2)   tar xjf $1        ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1       ;;
             *.rar)       unrar e $1     ;;
             *.gz)        gunzip $1     ;;
             *.tar)       tar xf $1        ;;
             *.tbz2)      tar xjvf $1      ;;
             *.tgz)       tar xzvf $1       ;;
             *.zip)       unzip $1     ;;
             *.Z)         uncompress $1  ;;
             *.7z)        7z x $1    ;;
             *)           echo "'$1' cannot be extracted via extract()" ;;
         esac
else
         echo "'$1' is not a valid file"
fi
}
mktar(){ tar cvf  "${1%%/}.tar"     "${1%%/}/"; }
mktgz(){ tar cvzf "${1%%/}.tar.gz"  "${1%%/}/"; }
mktbz(){ tar cvjf "${1%%/}.tar.bz2" "${1%%/}/"; }

#vim -oN filea fileb filec
vo(){
   vim -o$# $*
}

#make a dir and cd into it
mcd(){
    mkdir -pv "$@"
    cd "$@"
}

#move to trash
del(){
    mv "$@" "~/.trash/"
}

# recursively fix dir/file permissions on a given directory
fix() {
  if [ -d $1 ]; then
    find $1 -type d -exec chmod 755 {} \;
    find $1 -type f -exec chmod 644 {} \;
  else
    echo "$1 is not a directory."
  fi
}

# display a sweet clock
clock () {
  while true; do
    clear;
    echo "";
    echo "    $(date +%r)";
    echo "";
    sleep 1;
  done
}

# save a file to ~/tmp
saveit() {
  cp $1 ${HOME}/tmp/${1}.saved
}


# switch two files (comes in handy)
switchfile() {
  mv $1 ${1}.tmp && mv $2 $1 && mv ${1}.tmp $2
}

# View most commonly used commands. depends on your history output format
used(){
if [ $1 ]
then
    history | awk '{print $4}' | sort | uniq -c | sort -nr | head -n $1
else
    history | awk '{print $4}' | sort | uniq -c | sort -nr | head -n 10
fi
}

#if dir,cd into it. if file ,cd into where the file is
goto(){ [ -d "$1" ] && cd "$1" || cd "$(dirname "$1")"; }

mvtmp(){
  mv $1 ~/tmp/
}

function cptmp(){
  cp -r $1 ~/tmp/
}

# grep for a process
function psg {
  FIRST=`echo $1 | sed -e 's/^\(.\).*/\1/'`
  REST=`echo $1 | sed -e 's/^.\(.*\)/\1/'`
  ps aux | grep "[$FIRST]$REST"
}
