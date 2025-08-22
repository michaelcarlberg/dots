#!/bin/sh
# shellcheck disable=2155

umask 022

export GPG_DEFAULT_ID=0xEFBC5C49C8205280

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_RUNTIME_DIR="$HOME/.local/var/run"
export XDG_STATE_HOME="$HOME/.local/state"

export SVDIR="$HOME/.local/sv"
export SVDIR_X11="$HOME/.local/sv.x11"
export ETCSVDIR="$HOME/.runit/sv"
export SVWAIT=15

export TZ=Europe/Stockholm
export LANG=en_US.UTF-8

export EDITOR=nvim
export VISUAL=nvim
export PAGER=nvimpager
export PERLDOC_PAGER="$PAGER"
export INPUTRC="$XDG_CONFIG_HOME/inputrc"

export EMACSDIR="$HOME/.emacs.d"
export DOOMDIR="$HOME/.doom.d"

export HISTSIZE=20000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth
export HISTIGNORE='rm -rf:rm \*:sudo rm:shred'

export LESS="-g -I -M -R -S -w -K -z-4 --use-color --mouse --wheel-lines 10 --lesskey-file=$XDG_CONFIG_HOME/lesskey"
export LESSHISTFILE="$XDG_CACHE_HOME/lesshst"
export GREP_COLORS='mt=2;38;5;11;7'

export SHELLCHECK_OPTS="--exclude=1090 --source-path=SCRIPTDIR:$HOME/.local/lib/sh --external-sources"
export FZF_DEFAULT_OPTS="--prompt 'Loading# ' --marker '+' --preview 'test -f {} && cat {} | python -m pygments' --ansi \
  --height=25 --layout=reverse --inline-info --cycle \
  --no-bold --scrollbar='┃' --preview-window=hidden:border-sharp \
  --bind 'load:change-prompt:# ' \
  --bind 'focus:transform-preview-label:echo [ {} ]' \
  --bind 'ctrl-u:page-up' \
  --bind 'ctrl-d:page-down' \
  --bind 'ctrl-a:toggle-all' \
  --bind 'ctrl-s:toggle-sort' \
  --bind 'ctrl-o:execute(notify-send {})' \
  --bind 'ctrl-v:toggle-preview' \
  --bind 'ctrl-j:down' \
  --bind 'ctrl-k:up' \
  --bind 'alt-shift-down:preview-page-down' \
  --bind 'alt-shift-up:preview-page-up' \
  --bind 'ctrl-/:toggle-preview' \
  --bind 'ctrl-h:change-header:<C-/> preview' \
  --color='bg:-1,bg+:-1' \
  --color='fg:bright-black,fg+:white' \
  --color='hl+:bright-red:reverse' \
  --color='hl:red' \
  --color='border:19,gutter:red:-1' \
  --color='header:red,info:red' \
  --color='label:bright-white' \
  --color='scrollbar:bright-black' \
  --color='preview-label:red' \
  --color='preview-border:bright-black' \
  --color='marker:red' \
  --color='pointer:bright-red:bold' \
  --color='prompt:red:bold' \
  --color='separator:red:bold' \
  --color='query:bright-white:regular' \
  --color='spinner:red'"

export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export KPDB="$HOME/.keepass/vault.kdbx"
export KPDB_PASSFILE="$HOME/.keepass/vault.pass.gpg"
export CONAN_USER_HOME="$XDG_CONFIG_HOME"
# export ANDROID_HOME="$HOME/.android"
export ANDROID_SDK_ROOT="$HOME/.local/var/android-sdk"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export NCDC_DIR="$XDG_CONFIG_HOME/ncdc"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export SQLITE_HISTORY="$XDG_CACHE_HOME/sqlite_history"
export JAVA_HOME=/usr/lib/jvm/openjdk21
# export _JAVA_OPTIONS="-Djava.util.prefs.userRoot=${XDG_CONFIG_HOME}/java"
export _JAVA_AWT_WM_NONREPARENTING=1
export __GL_SHADER_DISK_CACHE_PATH="$XDG_CACHE_HOME/nv"
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=kvantum
export GTK_USE_PORTAL=0
export WXSUPPRESS_SIZER_FLAGS_CHECK=1
export FLYCTL_INSTALL="$HOME/.fly"
export ARDUINO_DIR="$HOME/.arduino15"
export ARDMK_DIR="$HOME/.local/src/arduino/arduino-makefile"
export SDKMAN_DIR="$XDG_DATA_HOME/sdkman"
export MAVEN_OPTS="-Dstyle.color=always"

export GOPATH="$HOME/.local/var/go"
export GOBIN="$GOPATH/bin"
export GOENV="$GOPATH/env"

export PERL_HOME="$HOME/.local/var/perl5"
export PERL5LIB="$PERL_HOME/lib/perl5"
export PERL_LOCAL_LIB_ROOT="$PERL_HOME"
export PERL_MB_OPT="--install_base $PERL_HOME"
export PERL_MM_OPT="INSTALL_BASE=$PERL_HOME"

# export PYTHONPATH="$HOME/.local/lib/python/site-packages:$PYTHONPATH"
# export PYTHONSTARTUP="$XDG_CONFIG_HOME/pythonrc"
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"

export NPM_CONFIG_PREFIX="$XDG_DATA_HOME/npm"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"

export MANPATH="$XDG_DATA_HOME/man:/usr/local/share/man:/usr/share/man"
export MANPATH="$NPM_CONFIG_PREFIX/share/man:$MANPATH"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
export PATH="$XDG_DATA_HOME/coursier/bin:$PATH"
export PATH="$XDG_DATA_HOME/nvim/mason/bin:$PATH"
export PATH="$SDKMAN_DIR/bin:$PATH"
export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"
export PATH="$PNPM_HOME:$PATH"
export PATH="$GOBIN:$PATH"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="$CARGO_HOME/bin:$PATH"
export PATH="$PYENV_ROOT/bin:$PATH"
export PATH="$HOME/.local/lib/sh:$PATH"
export PATH="$HOME/.local/bin:$PATH"

eval "$(luarocks path --no-bin)"

[ "$BASH_VERSION" ] && . ~/.bashrc

[ -f "/home/jaagr/.ghcup/env" ] && . "/home/jaagr/.ghcup/env" # ghcup-env
