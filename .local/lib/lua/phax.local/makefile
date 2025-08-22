all: clean generate

clean:
	@printf -- "[0;1mRemoving generated files...[0m\n"
	@rm -vrf colors
	@rm -vrf lua
	@rm -vrf phax

generate:
	@printf -- "[0;1mGenerating colorscheme...[0m\n"
	$(shell colorgen-nvim phax.toml)
	@mv -v phax/* .
	@rm -vrf phax

.PHONY: all
