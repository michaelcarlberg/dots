#!/usr/bin/env bash

alias xupd='sudo xupd'
alias xreconf='sudo xbps-reconfigure -f'
alias xfiles='xls'
alias xlist='xbps-query -l'

alias gosv='cd ~/.runit/sv'
alias govoid='cd /opt/xbps-mini-builder'

alias svlogcurrent='ps -C runsvdir -o command --no-heading'

alias svstart='sudo sv start'
alias svrestart='sudo sv restart'
alias svstop='sudo sv stop'
alias svenable='sudo sv enable'
alias svdisable='sudo sv disable'
alias svstart-l='sv -u start'
alias svrestart-l='sv -u restart'
alias svstop-l='sv -u stop'
alias svenable-l='sv -u enable'
alias svdisable-l='sv -u disable'
alias svlist-l='svlist -u'

if [ -r /usr/local/share/bash-completion/completions/sv ]; then
  . /usr/local/share/bash-completion/completions/sv
elif [ -r /usr/share/bash-completion/completions/sv ]; then
  . /usr/share/bash-completion/completions/sv
fi

complete -o default -F _sv \
  svstart \
  svrestart \
  svstop \
  svenable \
  svdisable \
  svstart-l \
  svrestart-l \
  svstop-l \
  svdisable-l \
  svenable-l
