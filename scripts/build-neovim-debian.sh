#!/usr/bin/bash -ex

if [ $# -eq 0 ]; then
  set "$(mktemp -d)"
fi

mkdir -p "$1"
pushd "$1"

# dependencies {{{

sudo apt-get update
sudo apt-get install -y \
  autoconf \
  automake \
  cmake \
  g++ \
  gettext \
  libncurses5-dev \
  libtool \
  libtool-bin \
  libunibilium-dev \
  libunibilium4 \
  ninja-build \
  pkg-config \
  python3-pip \
  software-properties-common \
  unzip

# }}}
# python and node modules {{{

pip3 install setuptools
pip3 install --upgrade pynvim

sudo npm install -g neovim

# }}}
# neovim {{{

if [ ! -d .git ]; then
  git clone https://github.com/neovim/neovim .
fi

git pull origin

make distclean

make CMAKE_BUILD_TYPE=RelWithDebInfo CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/usr/local/"
sudo make install

echo "nvim command: $(command -v nvim)"
echo "nvim command: $(ls -al "$(command -v nvim)")"

# }}}

popd
