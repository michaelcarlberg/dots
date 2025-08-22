#!/usr/bin/env bash

# COMMENT_PREFIX='shfmt'

if :; then
    # shfmt:ignore
        echo $foo
  declare foo
    # shfmt:ignore
    #
    #
    # s
          echo $foo
  echo "$foo"

  # shfmt:ignore-begin
      echo $foo
  echo $foo
  # shfmt:ignore-end
  echo "$foo"
  sed -r -f >/dev/stdin <<-EOF
    /${COMMENT_PREFIX}:ignore-begin/,/${COMMENT_PREFIX}:ignore-end/{
      s/^/# ${COMMENT_PREFIX}:parser-ignore-line/
    }
    /${COMMENT_PREFIX}:ignore[^-]*/{
      s/^/# ${COMMENT_PREFIX}:parser-ignore-line/
    }
	EOF
  sed -r "s/# ${COMMENT_PREFIX}:parser-ignore-line//g"
fi
