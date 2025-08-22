#!/usr/bin/env bash

if command -v pnpm >/dev/null; then
  # shellcheck disable=2154
  alias pnph='alias -p  | egrep " pn" | sed -nr -e "/pnph/d" -e "s/alias ([^ ]+)='\''(.*)'\''/\1:\2/p" | while IFS=: read -r alias cmd; do printf "[0;1;32m% 15s [0;2;34m│[0m %s\n" "$alias" "$cmd"; done | sort -r'
  alias pna='pnpm add'
  alias pnad='pnpm add --save-dev'
  alias pnap='pnpm add --save-peer'
  alias pnau='pnpm audit'
  alias pnb='pnpm run build'
  alias pnB='pnpm run clean; pnpm run build'
  alias pnbw='pnpm run build -w'
  alias pnc='pnpm create'
  alias pnd='pnpm run dev'
  alias pndoc='pnpm run doc'
  alias pnga='pnpm add --global'
  alias pngls='pnpm list --global'
  alias pngrm='pnpm remove --global'
  alias pngu='pnpm update --global'
  alias pnh='pnpm help'
  alias pni='pnpm init'
  alias pnin='pnpm install'
  alias pnln='pnpm run lint'
  alias pnls='pnpm list'
  alias pnout='pnpm outdated'
  alias pnp='pnpm'
  alias pnpub='pnpm publish'
  alias pnrm='pnpm remove'
  alias pnrun='pnpm run'
  alias pns='pnpm run serve'
  alias pnst='pnpm start'
  alias pnsv='pnpm server'
  alias pnt='pnpm test'
  alias pntc='pnpm test --coverage'
  alias pnui='pnpm update --interactive'
  alias pnuil='pnpm update --interactive --latest'
  alias pnun='pnpm uninstall'
  alias pnup='pnpm update'
  alias pnwhy='pnpm why'
  alias pnx='pnpx'
fi

if command -v npm >/dev/null; then
  _npm_complete()
  {
    declare -a COMPREPLY_FILTER=(in ins inst insta instal isnt isnta isntal isntall isntall-clean hlep)

    readarray -t COMPREPLY < <(COMP_CWORD="$COMP_CWORD" COMP_LINE="$COMP_LINE" COMP_POINT="$COMP_POINT" npm completion -- "${COMP_WORDS[@]}" 2>/dev/null)

    for word in "${!COMPREPLY[@]}"; do
      if [ "${COMPREPLY[word]}" = "run-script" ]; then
        COMPREPLY[word]="run"
      fi

      # shellcheck disable=2076
      if [[ " ${COMPREPLY_FILTER[*]} " =~ " ${COMPREPLY[word]} " ]]; then
        unset -v 'COMPREPLY[$word]'
      fi
    done

    if type __ltrim_colon_completions &>/dev/null; then
      __ltrim_colon_completions "${COMP_WORDS[COMP_CWORD]}"
    fi
  }

  _bind_complete npm _npm_complete
fi
