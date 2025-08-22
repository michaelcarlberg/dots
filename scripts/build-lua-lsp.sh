#!/usr/bin/bash -ex

if [ $# -eq 0 ]; then
  set "$(mktemp -d)"
fi

mkdir -p "$1"
cd "$1"

if [ ! -d lua-language-server ]; then
  git clone --depth=1 https://github.com/sumneko/lua-language-server
fi

cd lua-language-server
git pull
# sudo dnf install -y libstdc++-static
./make.sh

set +x
read -r -p "Link binaries? [Y/n] " answer

if [ "${answer^^}" = "Y" ]; then
  set -x
  mkdir -p ~/.local/bin
  ln -sf "$PWD/3rd/luamake/luamake" ~/.local/bin/
  ln -sf "$PWD/bin/lua-language-server" ~/.local/bin/
fi
