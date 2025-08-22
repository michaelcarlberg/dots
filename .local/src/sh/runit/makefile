TARGETS     = sv svlist svlogtail

PREFIX      ?= /usr/local
BINPREFIX   ?= $(PREFIX)/bin
COMPPREFIX  ?= $(PREFIX)/share/bash-completion/completions

CSCRIPT     := SHELLSCRIPTLOADER_COMPILER=compiler ./compile.sh
CFLAGS      += -O -a /home/jaagr/.local/lib/sh -s "'/usr/bin/env bash'"
MAKEFLAGS   += -Rrk
CHECKFLAGS  += -Calways

FMT1 = [0\;34m┍━━┥
FMT2 = [0\;34m│ [0;2m
FMT3 = [0\;34m└──────────────╸[0m

ifeq ($(findstring n,$(MAKEFLAGS)),n)
define run_command
	@$2 2>&1
endef
else
define run_command
	@echo $(FMT1) $1
	@(set -x; $2) 2>&1 | sed 's/^/$(FMT2)/'; exit $$PIPESTATUS
	@echo $(FMT3)
endef
endif

all: build

check/bin/%: %.sh
	$(call run_command,checking: $<,shellcheck $(CHECKFLAGS) $<)
check/comp/%: bash-completions/%
	$(call run_command,checking: $<,shellcheck $(CHECKFLAGS) $<)
check: \
	$(patsubst %,check/bin/%,$(TARGETS)) \
	$(patsubst %,check/comp/%,$(TARGETS))

build/bin/%: %.sh
	@mkdir -p $(dir $@)
	$(call run_command,building: $@,$(CSCRIPT) $< $@ $(CFLAGS))
build/comp/%: bash-completions/%
	@mkdir -p $(dir $@)
	$(call run_command,building: $@,$(CSCRIPT) $< $@ $(CFLAGS))
build: \
	$(patsubst %,build/bin/%,$(TARGETS)) \
	$(patsubst %,build/comp/%,$(TARGETS))

install/bin/%: build/bin/%
	@install -v -Dm755 $< $(DESTDIR)$(BINPREFIX)/$*
install/comp/%: build/comp/%
	@install -v -Dm644 $< $(DESTDIR)$(COMPPREFIX)/$*
install: \
	$(patsubst %,install/bin/%,$(TARGETS)) \
	$(patsubst %,install/comp/%,$(TARGETS))

uninstall:
	@rm -rf $(patsubst %,$(DESTDIR)$(BINPREFIX)/%,$(TARGETS))
	@rm -rf $(patsubst %,$(DESTDIR)$(COMPPREFIX)/%,$(TARGETS))

clean:
	@rm -vrf build

.PHONY: all check uninstall clean

# vim:ts=2 sw=2 noet list
