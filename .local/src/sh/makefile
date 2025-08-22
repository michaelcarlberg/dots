DESTDIR := $(shell readlink -f ~/scripts)

FILES := $(wildcard *.sh)
FILES := $(filter-out shellharden.sh, $(FILES))
FILES := $(filter-out shfmt.sh, $(FILES))
FILES := $(filter-out test.sh, $(FILES))

all: link

link:
	@mkdir -pv $(DESTDIR)
	@for f in $(FILES); do ln -svf $(shell pwd)/$$f $(DESTDIR)/$$f; done

unlink:
	@rm -vf $(patsubst %,$(DESTDIR)/%,$(FILES))

clean: unlink

.PHONY: all link clean unlink
