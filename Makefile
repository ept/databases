SHELL=/bin/bash
LATEX=pdflatex -shell-escape -halt-on-error -file-line-error

# The example database that slides and notes draw their data from. Its contents change
# from year to year, its schema does not. moviedb-generator produces SQLite; movies.sql is
# the vendor-neutral dump of that (see moviedb-generator/README.md), and
# examples/duckdb-import.py replays it into DuckDB, which is what the course uses. To move
# to a new year's data:
#
#     make database MOVIEDB=moviedb-2027/movies.duckdb   # replay the dump
#     make refresh  MOVIEDB=moviedb-2027/movies.duckdb   # re-run every query
#     git diff examples/                                 # review what changed
#     make
#
MOVIEDB ?= moviedb-2025/movies.duckdb

# One query per file in examples/, each rendered to a LaTeX fragment that databases.tex
# pulls in with \input. Only data derived from the database *contents* lives here;
# anything that follows from the schema alone is hard-coded in databases.tex.
EXAMPLE_SQL := $(sort $(wildcard examples/*.sql))
EXAMPLE_TEX := $(EXAMPLE_SQL:.sql=.tex)

.SUFFIXES: .tex .bib .aux .bbl .dvi .ps .pdf .thy
.PRECIOUS: %.aux
.PHONY: all examples refresh clean database

all:	databases-notes.pdf databases-slides.pdf solutions.pdf

%.pdf: %.tex %.aux
	$(LATEX) $<
	while grep 'Rerun to get ' $*.log; do $(LATEX) $<; done

%.aux:	%.tex
	$(LATEX) $<

%.bbl:	references.bib %.aux
	bibtex $*

# Render the query results. The dependency on the database is via $(wildcard ...) so that
# the document still builds from the committed examples/*.tex when the database is absent.
examples/%.tex:	examples/%.sql examples/render.py $(wildcard $(MOVIEDB))
	python3 examples/render.py $(MOVIEDB) $<

examples: $(EXAMPLE_TEX)

# Replay the SQLite dump into DuckDB. Both files are gitignored, so a fresh clone has
# neither and simply builds the document from the committed examples/*.tex.
%.duckdb: %.sql examples/duckdb-import.py
	python3 examples/duckdb-import.py $< $@

database: $(MOVIEDB)

# Re-run every query, e.g. after switching to a new year's database.
refresh:
	rm -f $(EXAMPLE_TEX)
	$(MAKE) examples

# Actually depends on exercises.tex, which is generated as a side-effect of building databases-notes.pdf
solutions.pdf: databases-notes.pdf

# Slides from databases-handout.pdf are embedded in the notes
databases-notes.pdf:	databases-handout.pdf databases-notes.bbl

databases-handout.pdf:	databases.tex $(EXAMPLE_TEX)

databases-slides.pdf:	databases.tex $(EXAMPLE_TEX)

clean:
	rm -f {databases-{slides,handout,notes},solutions}.{log,aux,out,bbl,blg,nav,snm,toc,dvi,ps,pdf}
