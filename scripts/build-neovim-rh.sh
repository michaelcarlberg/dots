#!/usr/bin/bash -ex

if [ $# -eq 0 ]; then
  set "$(mktemp -d)"
fi

mkdir -p "$1"
pushd "$1"

# dependencies {{{

sudo dnf -y install \
  ninja-build \
  libtool \
  autoconf \
  automake \
  cmake \
  gcc \
  gcc-c++ \
  make \
  pkgconfig \
  unzip \
  patch \
  gettext \
  curl

# }}}
# python and node modules {{{

pip install setuptools
pip install --upgrade pynvim

npm install -g neovim

# }}}
# neovim {{{

if [ ! -d .git ]; then
  git clone --depth 1 https://github.com/neovim/neovim .
fi

git pull origin

make distclean

make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local/"
make install

echo "nvim command: $(command -v nvim)"
echo "nvim command: $(ls -al "$(command -v nvim)")"

# }}}

popd
