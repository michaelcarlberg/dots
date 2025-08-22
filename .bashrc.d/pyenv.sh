#!/usr/bin/env bash

export PYENV_ROOT="$HOME/.pyenv"

if [ -d "$PYENV_ROOT/bin" ]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
fi

pyenv-init()
{
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
}

# if [ -f ./requirements.txt ] || [ -f ./setup.py ]; then
#   pyenv-init
# fi

pyenv-venv-local()
{
  pyenv-init

  set -- "${1:-.venv}"

  [ -d "$1" ] || {
    printf "[pyenv.sh] Creating: %s\n" "$1"
    python -m venv "$1"
  }

  printf "[pyenv.sh] Activating: %s\n" "$1"
  # shellcheck source=/dev/null
  source "$1/bin/activate"
}
