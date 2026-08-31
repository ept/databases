SHELL=/bin/bash
LATEX=pdflatex -shell-escape -halt-on-error -file-line-error

.SUFFIXES: .tex .bib .aux .bbl .dvi .ps .pdf .thy
.PRECIOUS: %.aux

all:	databases-notes.pdf databases-slides.pdf solutions.pdf

%.pdf: %.tex %.aux
	$(LATEX) $<
	while grep 'Rerun to get ' $*.log; do $(LATEX) $<; done

%.aux:	%.tex
	$(LATEX) $<

%.bbl:	references.bib %.aux
	bibtex $*

# Actually depends on exercises.tex, which is generated as a side-effect of building databases-notes.pdf
solutions.pdf: databases-notes.pdf

# Slides from databases-handout.pdf are embedded in the notes
databases-notes.pdf:	databases-handout.pdf databases-notes.bbl

databases-handout.pdf:	databases.tex

databases-slides.pdf:	databases.tex

clean:
	rm -f {databases-{slides,handout,notes},solutions}.{log,aux,out,bbl,blg,nav,snm,toc,dvi,ps,pdf}
