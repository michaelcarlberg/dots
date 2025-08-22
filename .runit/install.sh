#!/bin/sh

set -e

cd "${0%/*}"

install -v -d /etc/sv/runsvdir-jaagr
install -v -m755 sv/runsvdir-jaagr/run /etc/sv/runsvdir-jaagr/run
install -v -m755 sv/runsvdir-jaagr/finish /etc/sv/runsvdir-jaagr/finish

ln -vnsf /run/runit/supervise.runsvdir-jaagr /etc/sv/runsvdir-jaagr/supervise
