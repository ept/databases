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
# tables movies(movie_id, movie) and people(person_id, person), one document per row.
MOVIEDB_JSON ?= $(MOVIEDB:.duckdb=-json.duckdb)

# The same data as a property graph for Traverse (https://truespar.com/traverse), the same
# graph that moviedb-generator loads into Neo4j. Students upload the .tvdb file to the
# browser app at https://traverse.truespar.com/.
MOVIEDB_TVDB ?= $(MOVIEDB:.duckdb=.tvdb)

# The same data as Datalog facts for Souffle (https://souffle-lang.github.io/): a directory
# of tab-separated .facts files, one per relation, as declared in code/movies-schema.dl.
MOVIEDB_SOUFFLE ?= $(MOVIEDB:.duckdb=-souffle)

# One query per file in examples/, each rendered to a LaTeX fragment that databases.tex
# pulls in with \input. Only data derived from the database *contents* lives here;
# anything that follows from the schema alone is hard-coded in databases.tex.
EXAMPLE_SQL := $(sort $(wildcard examples/*.sql))
EXAMPLE_CYPHER := $(sort $(wildcard examples/*.cypher))
EXAMPLE_DATALOG := $(sort $(wildcard examples/*.dl))
EXAMPLE_TEX := $(EXAMPLE_SQL:.sql=.tex) $(EXAMPLE_CYPHER:.cypher=.tex) $(EXAMPLE_DATALOG:.dl=.tex)

# The Datalog listings, highlighted by pygmentize into code/highlighted/ (see the rule further
# down). Defined here, before the rules for the PDFs, because Make expands a rule's
# prerequisites as it reads the rule: a variable defined later in the file would still be
# empty there, and the PDFs would not be rebuilt when a listing changes.
DATALOG_LISTINGS := $(sort $(wildcard code/*.dl))
DATALOG_HIGHLIGHTED := $(patsubst code/%.dl,code/highlighted/%.tex,$(DATALOG_LISTINGS)) \
	code/highlighted/souffle-style.tex

.SUFFIXES: .tex .bib .aux .bbl .dvi .ps .pdf .thy
.PRECIOUS: %.aux
.PHONY: all examples refresh clean database database-json database-graph database-datalog database-datalog-zip check-datalog \
	playground-sql playground-json playground-datalog

all:	databases-notes.pdf databases-slides.pdf databases-solutions.pdf databases-exercises.pdf

# Run pdflatex again only when the layout is not yet settled: when LaTeX asks for a rerun
# (cross-references), or when the run changed the .aux file. The second test is what catches
# the TikZ drawings with [remember picture] (the circles, braces and lines on some slides):
# their positions are recorded in the .aux and only used on the next run, and LaTeX does not
# ask for a rerun when they move. If a run leaves the .aux as it was, nothing has moved, so
# a normal edit costs one run. At most three extra runs, in case something never settles.
%.pdf: %.tex %.aux
	@cp $*.aux $*.aux.before
	$(LATEX) $<
	@for i in 1 2 3; do \
	    if grep -q 'Rerun to get ' $*.log || ! cmp -s $*.aux $*.aux.before; then \
	        echo "*** $*.aux changed or LaTeX asked for a rerun: running pdflatex again"; \
	        cp $*.aux $*.aux.before; \
	        $(LATEX) $< || exit 1; \
	    else \
	        break; \
	    fi; \
	done; \
	rm -f $*.aux.before

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

# Queries in .cypher files run in Traverse against the graph version of the database.
examples/%.tex:	examples/%.cypher examples/render.py examples/traverse-query.mjs \
		examples/traverse-engine.mjs $(wildcard $(MOVIEDB_TVDB))
	uv run examples/render.py $(MOVIEDB_TVDB) $<

# Datalog programs in .dl files run in Souffle against the fact files.
examples/%.tex:	examples/%.dl examples/render.py code/movies-schema.dl \
		$(wildcard $(MOVIEDB_SOUFFLE)/movies.facts)
	uv run examples/render.py $(MOVIEDB_SOUFFLE) $<

examples: $(EXAMPLE_TEX)

# Replay the SQLite dump into DuckDB. Both files are gitignored, so a fresh clone has
# neither and simply builds the document from the committed examples/*.tex.
%.duckdb: %.sql examples/duckdb-import.py
	uv run examples/duckdb-import.py $< $@

database: $(MOVIEDB)

%-json.duckdb: %.tinydb.json examples/duckdb-import-json.py
	uv run examples/duckdb-import-json.py $< $@

database-json: $(MOVIEDB_JSON)

# The Traverse import runs Traverse's WebAssembly engine under Node (see the comment at the
# top of examples/traverse-import.mjs), installed from package-lock.json. npm writes
# node_modules/.package-lock.json on every install, so it serves as the timestamp.
node_modules/.package-lock.json: package.json package-lock.json
	npm ci --ignore-scripts --no-audit --no-fund

%.tvdb: %.tinydb.json examples/traverse-import.mjs examples/traverse-engine.mjs \
		node_modules/.package-lock.json
	node examples/traverse-import.mjs $< $@

database-graph: $(MOVIEDB_TVDB)

# The facts are exported from the relational database; movies.facts stands for the whole
# directory, since every export writes all the files.
%-souffle/movies.facts: %.duckdb examples/souffle-export.py
	uv run examples/souffle-export.py $< $(@D)

database-datalog: $(MOVIEDB_SOUFFLE)/movies.facts

# For students to download from the course web page and run with Souffle on their own
# machine: a movies-souffle/ directory with the schema, the facts, an example program and a
# README. Python's zipfile stands in for zip, which not every system has.
$(MOVIEDB_SOUFFLE).zip: $(MOVIEDB_SOUFFLE)/movies.facts code/movies-schema.dl code/datalog-join.dl \
		datalog-download/README.txt
	rm -f $@
	python3 -c 'import glob, os, sys, zipfile; \
	    z = zipfile.ZipFile(sys.argv[1], "w", zipfile.ZIP_DEFLATED); \
	    z.write("datalog-download/README.txt", "movies-souffle/README.txt"); \
	    z.write("code/movies-schema.dl", "movies-souffle/movies-schema.dl"); \
	    z.write("code/datalog-join.dl", "movies-souffle/example.dl"); \
	    [z.write(f, "movies-souffle/facts/" + os.path.basename(f)) for f in sorted(glob.glob(sys.argv[2] + "/*.facts"))]; \
	    z.close()' $@ $(MOVIEDB_SOUFFLE)

database-datalog-zip: $(MOVIEDB_SOUFFLE).zip

# Runs each Datalog example in code/datalog-*.dl and its SQL equivalent in code/datalog-*.sql,
# and checks that they give the same result.
check-datalog: $(MOVIEDB_SOUFFLE)/movies.facts
	uv run examples/datalog-check.py $(MOVIEDB) $(MOVIEDB_SOUFFLE)

# Re-run every query, e.g. after switching to a new year's database.
refresh:
	rm -f $(EXAMPLE_TEX)
	$(MAKE) examples

# Actually depends on exercises.tex, which is generated as a side-effect of building databases-notes.pdf
databases-solutions.pdf: databases-notes.pdf
databases-exercises.pdf: databases-notes.pdf

# Slides from databases-handout.pdf are embedded in the notes
databases-notes.pdf:	databases-handout.pdf databases-notes.bbl

databases-handout.pdf:	databases.tex setup.tex $(EXAMPLE_TEX) $(DATALOG_HIGHLIGHTED)

databases-slides.pdf:	databases.tex setup.tex $(EXAMPLE_TEX) $(DATALOG_HIGHLIGHTED)

clean:
	rm -f databases-{slides,handout,notes,solutions,exercises}.{log,aux,aux.before,out,bbl,blg,nav,snm,toc,dvi,ps,pdf}

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

# The JSON version of the shell, in playground-json/, loads the JSON documents and takes the
# engine and CLI from ../playground-sql/shell/, so it needs that directory built as well.
# Upload playground-json/ and playground-sql/ side by side.
playground-json/movies-json.duckdb.gz: $(MOVIEDB_JSON)
	gzip -9 -c $< > $@

playground-json: playground-json/movies-json.duckdb.gz playground-sql

# The Datalog playground: Souffle compiled to WebAssembly, with the movies database as facts.
# Upload the whole playground-datalog/ directory to the course web page. souffle.js and
# souffle.wasm.gz are committed, since building them needs Emscripten; the rules below
# refresh them from a WebAssembly build in the souffle/ checkout whenever there is a newer
# one (see "WebAssembly" in souffle/README.md). The facts, the schema and the examples are
# generated here.
SOUFFLE_WASM_BUILD = souffle/build-wasm/src
DATALOG_EXAMPLES = $(patsubst code/%,playground-datalog/examples/%,$(wildcard code/datalog-*.dl))

playground-datalog/souffle.js: $(wildcard $(SOUFFLE_WASM_BUILD)/souffle.js)
	cp $< $@

playground-datalog/souffle.wasm.gz: $(wildcard $(SOUFFLE_WASM_BUILD)/souffle.wasm)
	gzip -9 -c $< > $@

playground-datalog/movies-schema.dl: code/movies-schema.dl
	cp $< $@

playground-datalog/examples/%.dl: code/%.dl
	@mkdir -p $(@D)
	cp $< $@

# All the fact files in one gzipped JSON object, {"movies": "<contents of movies.facts>", ...}
playground-datalog/movies-facts.json.gz: $(MOVIEDB_SOUFFLE)/movies.facts
	python3 -c 'import glob, json, os, sys; \
	    json.dump({os.path.basename(f)[:-6]: open(f).read() for f in sorted(glob.glob(sys.argv[1] + "/*.facts"))}, sys.stdout)' \
	    $(MOVIEDB_SOUFFLE) | gzip -9 > $@

playground-datalog: playground-datalog/souffle.js playground-datalog/souffle.wasm.gz \
	playground-datalog/movies-schema.dl playground-datalog/movies-facts.json.gz $(DATALOG_EXAMPLES)

# The Datalog listings are highlighted with the Souffle lexer in code/souffle_lexer.py, which
# minted cannot load itself (minted 2 has no way to pass pygmentize's -x option, and
# minted 3 only loads lexers listed in the user's own configuration). So pygmentize writes
# the highlighted LaTeX here, and \inputdatalog in setup.tex includes it with fvextra's
# \VerbatimInput. The commands are prefixed PYGdl so as not to clash with minted's PYG.
# The outputs are committed, like examples/*.tex, so a fresh clone builds without this step.

code/highlighted/%.tex: code/%.dl code/souffle_lexer.py
	pygmentize -l code/souffle_lexer.py:SouffleLexer -x -f latex -P commandprefix=PYGdl -P nowrap=True -o $@ $<

code/highlighted/souffle-style.tex:
	pygmentize -S default -f latex -P commandprefix=PYGdl > $@
