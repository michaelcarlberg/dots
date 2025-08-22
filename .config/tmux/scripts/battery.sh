#!/bin/bash

set -e

colorize()
{
  local -i percentage="${1:-100}"
  local -a styles=()

  if ((percentage < 25)); then
    styles+=('fg=red')
    styles+=('bg=black')
  elif ((percentage < 50)); then
    styles+=('fg=yellow')
    styles+=('bg=black')
  elif ((percentage < 75)); then
    styles+=('fg=yellow')
    styles+=('bg=black')
  else
    styles+=('fg=green')
    styles+=('bg=black')
  fi

  printf '%s\n' "${styles[*]// /,}"
}

percentage=$(acpi -b | sed -nr 's/.+, ([0-9]+)%.*/\1/p')

printf "#[%s]%s%%\n" "$(colorize "$percentage")" "$percentage"
