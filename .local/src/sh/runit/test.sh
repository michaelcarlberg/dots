#!/usr/bin/env bash
#
# runit service helper
#

set -eo pipefail

source bootstrap.sh

include utils/ansi.sh
echo "$ANSI_COLORS"
type include
bootstrap::finish

# post-pass: replace-eval
LOG_E=$(printf '<rd><b>error</b></rd>\n' | ansi::colorize-tags)

echo "$LOG_E"
