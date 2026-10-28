#!/usr/bin/env python3
"""Check that each Datalog program gives the same result as its SQL and Cypher equivalents.

Usage:  python3 examples/datalog-check.py moviedb-2025/movies-locations.duckdb moviedb-2025/movies-locations.tvdb moviedb-2025/movies-souffle

For every code/NAME.dl that has a code/NAME.sql or a code/NAME.cypher beside it (or both),
runs the Datalog program in Souffle on the fact files, the SQL query in DuckDB on the
relational database, and the Cypher query in Traverse on the graph database, and compares
the results as sets of rows (Datalog relations are sets, and the SQL and Cypher queries
need no ORDER BY). A SQL or Cypher result that contains the same row twice also counts as
a difference, since the Datalog result cannot. Exits with status 1 if any of them differ,
printing a few of the rows that are in only one of the two.

The databases are the versions with the filming locations (see locations/README.md), so
that recursive queries over them can be checked too.

A float in Souffle is 32 bits, so it would not compare equal to the 64-bit value in DuckDB;
floats are therefore compared to 6 significant digits.
"""

import glob
import os
import sys

import duckdb

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render import run_cypher, run_souffle  # noqa: E402


def normalise(row):
    out = []
    for value in row:
        if hasattr(value, 'as_tuple'):  # Decimal, e.g. DuckDB's NUMERIC
            value = float(value)
        if isinstance(value, float):
            value = float('%.6g' % value)
        out.append(value)
    return tuple(out)


def compare(name, language, datalog_rows, other_rows):
    """Print the outcome, and return True if the results are the same."""
    datalog_set = {normalise(r) for r in datalog_rows}
    other_set = {normalise(r) for r in other_rows}
    if datalog_set == other_set and len(other_set) == len(other_rows):
        print('  %-24s %-7s same result, %d rows' % (name, language, len(other_rows)))
        return True
    print('  %-24s %-7s DIFFERENT: %d rows in Datalog, %d in %s'
          % (name, language, len(datalog_set), len(other_rows), language))
    print('      only in Datalog:', sorted(datalog_set - other_set)[:5])
    print('      only in %-8s' % (language + ':'), sorted(other_set - datalog_set)[:5])
    if len(other_set) != len(other_rows):
        print('      (the %s result contains duplicate rows)' % language)
    return False


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    database, graph, facts = sys.argv[1], sys.argv[2], sys.argv[3]
    code = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'code')
    connection = duckdb.connect(database, read_only=True)
    ok = True
    for program in sorted(glob.glob(os.path.join(code, '*.dl'))):
        base = program[:-len('.dl')]
        name = os.path.basename(base)
        query, cypher = base + '.sql', base + '.cypher'
        if not os.path.exists(query) and not os.path.exists(cypher):
            continue
        _, datalog_rows = run_souffle(facts, program)
        if os.path.exists(query):
            sql_rows = connection.execute(open(query, encoding='utf-8').read()).fetchall()
            ok = compare(name, 'SQL', datalog_rows, sql_rows) and ok
        if os.path.exists(cypher):
            _, cypher_rows = run_cypher(graph, cypher)
            ok = compare(name, 'Cypher', datalog_rows, cypher_rows) and ok
    connection.close()
    sys.exit(0 if ok else 1)


if __name__ == '__main__':
    main()
