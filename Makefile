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

# The same data as JSON documents, built from the TinyDB export rather than the SQL dump:
# tables movies(movie_id, data) and people(person_id, data), one document per row.
MOVIEDB_JSON ?= $(MOVIEDB:.duckdb=-json.duckdb)

# One query per file in examples/, each rendered to a LaTeX fragment that databases.tex
# pulls in with \input. Only data derived from the database *contents* lives here;
# anything that follows from the schema alone is hard-coded in databases.tex.
EXAMPLE_SQL := $(sort $(wildcard examples/*.sql))
EXAMPLE_TEX := $(EXAMPLE_SQL:.sql=.tex)

.SUFFIXES: .tex .bib .aux .bbl .dvi .ps .pdf .thy
.PRECIOUS: %.aux
.PHONY: all examples refresh clean database database-json playground-sql

all:	databases-notes.pdf databases-slides.pdf databases-solutions.pdf

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
	uv run examples/render.py $(MOVIEDB) $<

# Queries named json-*.sql run against the JSON documents instead. Make prefers this rule
# over the one above for those files, because its stem is shorter.
examples/json-%.tex:	examples/json-%.sql examples/render.py $(wildcard $(MOVIEDB_JSON))
	uv run examples/render.py $(MOVIEDB_JSON) $<

examples: $(EXAMPLE_TEX)

# Replay the SQLite dump into DuckDB. Both files are gitignored, so a fresh clone has
# neither and simply builds the document from the committed examples/*.tex.
%.duckdb: %.sql examples/duckdb-import.py
	uv run examples/duckdb-import.py $< $@

database: $(MOVIEDB)

%-json.duckdb: %.tinydb.json examples/duckdb-import-json.py
	uv run examples/duckdb-import-json.py $< $@

database-json: $(MOVIEDB_JSON)

# Re-run every query, e.g. after switching to a new year's database.
refresh:
	rm -f $(EXAMPLE_TEX)
	$(MAKE) examples

# Actually depends on exercises.tex, which is generated as a side-effect of building databases-notes.pdf
databases-solutions.pdf: databases-notes.pdf

# Slides from databases-handout.pdf are embedded in the notes
databases-notes.pdf:	databases-handout.pdf databases-notes.bbl

databases-handout.pdf:	databases.tex setup.tex $(EXAMPLE_TEX)

databases-slides.pdf:	databases.tex setup.tex $(EXAMPLE_TEX)

clean:
	rm -f databases-{slides,handout,notes,solutions}.{log,aux,out,bbl,blg,nav,snm,toc,dvi,ps,pdf}

# The browser shell in playground-sql/ loads the database gzipped from next to its index.html.
# Upload the whole playground-sql/ directory to the course web page.
playground-sql/movies.duckdb.gz: $(MOVIEDB)
	gzip -9 -c $< > $@

# The shell itself is the one from https://shell.duckdb.org/: the DuckDB CLI's line editor
# compiled to Wasm (duckdb.js, duckdb.wasm), talking to a worker that runs the engine
# (worker.js, duckdb-eh.wasm). Those files are not published as a versioned package, and
# index.html depends on their internal interface, so we keep our own copies and check them
# against these hashes. If upstream changes and a download fails the check, test that
# index.html still works with the new files before updating the hash.
SHELL_ASSETS = https://shell.duckdb.org/static/assets
SHA256_duckdb.js      = b65d5395f5a0ed7b0a6124e69632fb7f46c298910830f80be9777003c390e42f
SHA256_duckdb.wasm    = a8f3228a23d7d51fc8aacea1cde14f4724d9544fe16c73b696e0f3ea5c1d67e5
SHA256_worker.js      = 28e3e7449af9ff89e715f43a27ea3e0ab85e0a3d4459b9f284fe5e573cb5063d
SHA256_duckdb-eh.wasm = 6f350e0d92bd4e420cd72bb36584315760914d69965baace25223c6a15380256

playground-sql/shell/%.download:
	@mkdir -p $(@D)
	curl -fsSL -o $@ $(SHELL_ASSETS)/$*
	@echo "$(SHA256_$*)  $@" | shasum -a 256 -c - || \
	    { echo "$(SHELL_ASSETS)/$* has changed upstream; see the comment in the Makefile"; rm -f $@; exit 1; }

playground-sql/shell/%: playground-sql/shell/%.download
	mv $< $@

# The engine is 36 MB, 8 MB gzipped; index.html decompresses it, like the database.
# The download is intermediate so that make deletes it afterwards, and does not fetch it
# again just because it is gone.
.INTERMEDIATE: playground-sql/shell/duckdb-eh.wasm.download
playground-sql/shell/duckdb-eh.wasm.gz: playground-sql/shell/duckdb-eh.wasm.download
	gzip -9 -c $< > $@

playground-sql: playground-sql/movies.duckdb.gz playground-sql/shell/duckdb.js playground-sql/shell/duckdb.wasm \
	playground-sql/shell/worker.js playground-sql/shell/duckdb-eh.wasm.gz
