main: check main.tex
	latexmk main.tex

.PHONY: clean
clean: check
	latexmk -C

.PHONY: check
check:
	@which perl > /dev/null
	@which latexmk > /dev/null
	@which platex > /dev/null
	@which pbibtex > /dev/null
	@which dvipdfmx > /dev/null
	@which biber > /dev/null
