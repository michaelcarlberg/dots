#!/usr/bin/bash -ex

if [ $# -eq 0 ]; then
  set "$(mktemp -d)"
fi

mkdir -p "$1"
pushd "$1"

# fasd {{{

if [ ! -f fasd-1.0.1.tar.gz ]; then
  wget https://github.com/clvv/fasd/archive/refs/tags/1.0.1.tar.gz -O fasd-1.0.1.tar.gz
fi

tar xvzf fasd-1.0.1.tar.gz

pushd fasd-1.0.1
  make install
popd

# }}}

popd
