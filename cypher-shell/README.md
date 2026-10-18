# Running Cypher queries on your own machine

The easiest way to try the graph queries in the Databases course is the Traverse app in
your web browser (see the lecture notes). If you prefer to work on the command line, this
directory contains a small shell that runs the same database engine on your own computer,
using [Node.js](https://nodejs.org/). Queries give the same results as in the browser,
since it is the same engine, but the results are shown as text tables rather than as a
picture of the graph.

## What you need

- **Node.js**, version 18 or later. To check whether you have it, open a terminal and run
  `node --version`. If the command is not found, or prints a version older than v18,
  install the current LTS version from <https://nodejs.org/>. (On macOS with Homebrew,
  `brew install node` also works.)
- **This directory**, `cypher-shell`, downloaded from the course web page as
  `cypher-shell.zip`, and unzipped.
- **The graph database**, `movies.tvdb`, from the course web page. This is the same file
  that you would upload to the browser app.

## Installing

Open a terminal in the `cypher-shell` directory, and run:

```
npm install
```

This downloads Traverse's database engine, the npm package
[`@truespar/traverse-wasm`](https://www.npmjs.com/package/@truespar/traverse-wasm), into a
subdirectory called `node_modules`. You only need to do this once.

## Running the shell

Start the shell, giving it the path of the database file (here, the file is assumed to be
in the directory above `cypher-shell`; adjust the path to wherever you saved it):

```
node cypher-shell.mjs ../movies.tvdb
```

You can then type Cypher queries. End each query with a semicolon; a query can span
several lines, and the shell waits for the semicolon before running it:

```
cypher> MATCH (p:Person {name: 'Steven Spielberg'})
    ...>       -[:DIRECTED]->(m:Movie)
    ...> RETURN m.title, m.year
    ...> ORDER BY m.year
    ...> LIMIT 3;
┌────────────────────────────────────┬────────┐
│ m.title                            │ m.year │
├────────────────────────────────────┼────────┤
│ Jaws                               │   1975 │
│ Close Encounters of the Third Kind │   1977 │
│ Raiders of the Lost Ark            │   1981 │
└────────────────────────────────────┴────────┘
3 rows
(18 ms)
```

Vertices, edges, and paths are shown in Cypher's own notation, for example
`(:Person {name: 'Charles Chaplin', ...})` for a vertex and `[:ACTED_IN {roles: [...]}]`
for an edge.

Besides queries, the shell understands a few commands, which start with a colon:

| Command | Effect |
|---|---|
| `:help` | List the commands |
| `:schema` | List the labels, relationship types, and property keys in the database |
| `:rows N` | Show at most N rows of each result (default 40) |
| `:save FILE.tvdb` | Save the database, including any changes you made, to a file |
| `:quit` | Exit (Ctrl-D also works) |

Ctrl-C discards a query that you have only partly typed. While a query is running,
Ctrl-C exits the shell; the engine cannot cancel a query part-way through.

## Running queries from a file

You can also write queries in a file, separated by semicolons, and run them all at once:

```
node cypher-shell.mjs ../movies.tvdb my-queries.cypher
```

Each query is printed, followed by its result. Lines starting with `//` are comments.
Output that goes to a file rather than the terminal is never truncated, so this also works
for saving results:

```
node cypher-shell.mjs ../movies.tvdb my-queries.cypher > results.txt
```

## Things to know

- **Your changes are not saved automatically.** The shell loads the database into memory,
  and queries that change it (`CREATE`, `SET`, `DELETE`, ...) only affect that copy. When
  you exit, the changes are gone, and the file is as you downloaded it, so feel free to
  experiment. Use `:save` if you do want to keep your changes, preferably to a different
  file.
- **The engine runs on a single CPU core** in this shell, whereas the browser app can use
  several, so some expensive queries may be slower here. For example, computing the Bacon
  numbers of all actors with `allShortestPaths` takes about a minute.
- **Traverse** is developed by Truespar (<https://truespar.com/traverse>), whose
  documentation describes the Cypher and GQL features it supports. The engine package was
  written for web browsers; `cypher-shell.mjs` provides the few browser features it needs
  so that it also runs under Node.js.
