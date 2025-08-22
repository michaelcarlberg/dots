#!/usr/bin/bash -ex

if [ $# -eq 0 ]; then
  set "$(mktemp -d)"
fi

mkdir -p "$1"
pushd "$1"

# libevent {{{
#
#if [ ! -f /usr/local/lib/libevent-.so ]; then
#  if [ ! -f libevent-2.1.11-stable.tar.gz ]; then
#    wget https://github.com/libevent/libevent/releases/download/release-2.1.11-stable/libevent-2.1.11-stable.tar.gz
#  fi
#  rm -rf libevent-2.1.11-stable
#  tar xvzf libevent-2.1.11-stable.tar.gz
#  pushd libevent-2.1.11-stable
#    ./configure --prefix=/usr/local
#    make
#    make install
#  popd
#fi
#
# }}}
# tmux {{{

if [ ! -f tmux-3.2.tar.gz ]; then
  wget https://github.com/tmux/tmux/releases/download/3.2/tmux-3.2.tar.gz
fi

rm -rf tmux-3.2
tar xvzf tmux-3.2.tar.gz

pushd tmux-3.2
  LDFLAGS="-L/usr/local/lib -Wl,-rpath=/usr/local/lib" ./configure --prefix=/usr/local
  make
  make install
popd

# }}}

popd
