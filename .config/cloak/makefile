PREFIX ?= $(HOME)/.local

SRC := wrapper.sh
BIN := cloak

GPG ?= $(GPG_DEFAULT_ID)
ACC := accounts.txt

all: decrypt

install: $(SRC)
	@install -vd $(DESTDIR)$(PREFIX)/bin
	@ln -vsf $(PWD)/$< $(DESTDIR)$(PREFIX)/bin/$(BIN)
	@install -vd $(DESTDIR)$(PREFIX)/share/bash-completion
	@ln -vsf $(PWD)/bash-completion $(DESTDIR)$(PREFIX)/share/bash-completion/completions/$(BIN)

encrypt:
	@diff --color=always --unified=0 --report-identical-files --suppress-common-lines $(ACC) $(patsubst %.txt,%,$(ACC)) || \
		read -r -p'[1mApply the changes [y/N][0m ' reply && [ $${reply:-'N'} = 'y' ] && \
		diff --unified=0 --report-identical-files --suppress-common-lines $(ACC) $(patsubst %.txt,%,$(ACC)) | patch $(ACC)
	@if [ -e $(ACC).gpg ]; then mv -vi $(ACC).gpg $(ACC).gpg.$$(date +%s); fi
	gpg -e -r $(GPG) $(ACC)

decrypt:
	gpg -d -r $(GPG) -o $(ACC) $(ACC).gpg

clean-all:
	@rm -vf $(ACC).gpg.*

.PHONY: install encrypt decrypt clean-all
