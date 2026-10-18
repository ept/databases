#!/usr/bin/env python3
"""Build a DuckDB database of JSON documents from the TinyDB export of the example database.

Usage:  python3 examples/duckdb-import-json.py moviedb-2025/movies.tinydb.json moviedb-2025/movies-json.duckdb

The result has two tables, movies(movie_id, movie) and people(person_id, person), with one
row per document: the key is the IMDb-style ID from the document ('tt...' or 'nm...'), not
the integer key under which TinyDB stores it, and the second column is the document itself
as JSON, named after what it describes so that queries read naturally (movie->>'title').
"""

import json
import os
import sys

import duckdb

TABLES = [('movies', 'movie_id', 'movie'), ('people', 'person_id', 'person')]


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    source, target = sys.argv[1], sys.argv[2]
    if not os.path.exists(source):
        sys.exit('%s: no such file' % source)
    if os.path.exists(target):
        os.remove(target)
    documents = json.load(open(source, encoding='utf-8'))
    connection = duckdb.connect(target)
    for table, key, column in TABLES:
        connection.execute('CREATE TABLE %s (%s TEXT PRIMARY KEY, %s JSON NOT NULL)'
                           % (table, key, column))
        rows = [(doc[key], json.dumps(doc, ensure_ascii=False)) for doc in documents[table].values()]
        connection.executemany('INSERT INTO %s VALUES (?, ?)' % table, rows)
        print('  %-14s %8d rows' % (table, len(rows)))
    connection.close()
    print('%s -> %s' % (source, target))


if __name__ == '__main__':
    main()
