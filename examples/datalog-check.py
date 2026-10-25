#!/usr/bin/env python3
"""Check that each Datalog example gives the same result as its SQL equivalent.

Usage:  python3 examples/datalog-check.py moviedb-2025/movies.duckdb moviedb-2025/movies-souffle

For every code/datalog-NAME.dl that has a code/datalog-NAME.sql beside it, runs the Datalog
program in Souffle on the fact files, and the SQL query in DuckDB on the relational database,
and compares the two results as sets of rows (Datalog relations are sets, and the SQL
queries need no ORDER BY). Exits with status 1 if any pair differs, printing a few of the
rows that are in only one of the two.

A float in Souffle is 32 bits, so it would not compare equal to the 64-bit value in DuckDB;
floats are therefore compared to 6 significant digits.
"""

import glob
import os
import sys

import duckdb

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from render import run_souffle  # noqa: E402


def normalise(row):
    out = []
    for value in row:
        if hasattr(value, 'as_tuple'):  # Decimal, e.g. DuckDB's NUMERIC
            value = float(value)
        if isinstance(value, float):
            value = float('%.6g' % value)
        out.append(value)
    return tuple(out)


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    database, facts = sys.argv[1], sys.argv[2]
    code = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'code')
    connection = duckdb.connect(database, read_only=True)
    failed = False
    for program in sorted(glob.glob(os.path.join(code, 'datalog-*.dl'))):
        query = program[:-len('.dl')] + '.sql'
        if not os.path.exists(query):
            continue
        name = os.path.basename(program)[:-len('.dl')]
        _, datalog_rows = run_souffle(facts, program)
        sql_rows = connection.execute(open(query, encoding='utf-8').read()).fetchall()
        datalog_set = {normalise(r) for r in datalog_rows}
        sql_set = {normalise(r) for r in sql_rows}
        if datalog_set == sql_set and len(sql_set) == len(sql_rows):
            print('  %-20s same result, %d rows' % (name, len(sql_rows)))
        else:
            failed = True
            print('  %-20s DIFFERENT: %d rows in Datalog, %d in SQL'
                  % (name, len(datalog_set), len(sql_rows)))
            print('      only in Datalog:', sorted(datalog_set - sql_set)[:5])
            print('      only in SQL:    ', sorted(sql_set - datalog_set)[:5])
            if len(sql_set) != len(sql_rows):
                print('      (the SQL result contains duplicate rows)')
    connection.close()
    sys.exit(1 if failed else 0)


if __name__ == '__main__':
    main()
