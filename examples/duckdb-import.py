#!/usr/bin/env python3
"""Build a DuckDB database by replaying the SQLite dump of the example database.

Usage:  python3 examples/duckdb-import.py moviedb-2025/movies.sql moviedb-2025/movies.duckdb

moviedb-generator produces SQLite, TinyDB and Neo4j; the .sql dump of the SQLite database
is its vendor-neutral form (see moviedb-generator/README.md), so that is what we replay.
The whole script is handed to DuckDB in one go rather than split on semicolons, because a
movie title may contain one.
"""

import os
import sys

import duckdb


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    dump, target = sys.argv[1], sys.argv[2]
    if not os.path.exists(dump):
        sys.exit('%s: no such dump' % dump)
    if os.path.exists(target):
        os.remove(target)          # replaying into an existing file would violate the keys
    script = open(dump, encoding='utf-8').read()
    connection = duckdb.connect(target)
    try:
        connection.execute(script)
    except duckdb.Error as error:
        connection.close()
        os.remove(target)
        sys.exit('%s: %s' % (dump, error))
    tables = [r[0] for r in connection.execute(
        "SELECT table_name FROM information_schema.tables ORDER BY table_name").fetchall()]
    for table in tables:
        count = connection.execute('SELECT count(*) FROM "%s"' % table).fetchone()[0]
        print('  %-14s %8d rows' % (table, count))
    connection.close()
    print('%s -> %s' % (dump, target))


if __name__ == '__main__':
    main()
