#!/usr/bin/bash -ex

if [ $# -eq 0 ]; then
  set "$(mktemp -d)"
fi

mkdir -p "$1"
pushd "$1"

#dnf -y groupinstall "Development Tools"
dnf -y install gmp-devel ghc cabal-install

cabal update
cabal install shellcheck
cp ~/.cabal/bin/shellcheck /usr/local/bin

popd
