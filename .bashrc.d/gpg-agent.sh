#!/usr/bin/env bash
# shellcheck disable=2155

alias gpg-agent-ls='echo keyinfo --list | gpg-connect-agent'
alias gpg-agent-editconf='vim ~/.local/share/gnupg/gpg-agent.conf && gpg-agent-reload'
alias gpg-agent-kill='echo killagent | gpg-connect-agent'
alias gpg-agent-reload='echo killagent | gpg-connect-agent; sleep 1; echo reloadagent | gpg-connect-agent'
alias gpg-agent-clear='gpg-agent-ls | head -n-1 | cut -d" " -f2-3 | sed "s/KEYINFO/DELETE_KEY/" | gpg-connect-agent'

export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"
unset SSH_AGENT_PID

gpg-connect-agent updatestartuptty /bye &>/dev/null
