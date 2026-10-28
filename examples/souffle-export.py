#!/usr/bin/env python3
"""Export the relational example database as Souffle fact files.

Usage:  python3 examples/souffle-export.py moviedb-2025/movies.duckdb locations moviedb-2025/movies-souffle

Writes one tab-separated <relation>.facts file per relation into the output directory,
which is the format Souffle's `.input` directive reads by default. The relations are those
declared in code/movies-schema.dl. Datalog has no NULL, so each column that can be null in
the relational schema becomes a relation of its own, with a fact only where the value is
known:

    people(person_id, name, birthyear, deathyear)
        -> people(person_id, name), birthyear(person_id, year), deathyear(person_id, year)
    has_position(person_id, movie_id, position, job)
        -> has_position(person_id, movie_id, position), job(person_id, movie_id, position, job)

Every other table becomes a relation with the same name and the same columns in the same
order.

The filming locations are not in the relational database: they come from Wikidata, and
locations/clean.py has already written them as fact files (see locations/README.md). They
are copied from the locations directory given as the second argument, except for the
filming locations of movies that are not in the database, which are left out (there are
none, unless the database has changed since the locations were last fetched).

The values contain no tabs, newlines or backslashes, which the fact file format
could not represent; the script checks this rather than assuming it.
"""

import os
import sys

import duckdb

RELATIONS = {
    'movies':       'SELECT movie_id, title, year, type, minutes FROM movies',
    'people':       'SELECT person_id, name FROM people',
    'birthyear':    'SELECT person_id, birthyear FROM people WHERE birthyear IS NOT NULL',
    'deathyear':    'SELECT person_id, deathyear FROM people WHERE deathyear IS NOT NULL',
    'genres':       'SELECT genre_id, name FROM genres',
    'has_genre':    'SELECT movie_id, genre_id FROM has_genre',
    'ratings':      'SELECT movie_id, CAST(rating AS DOUBLE), votes FROM ratings',
    'has_position': 'SELECT person_id, movie_id, position FROM has_position',
    'job':          'SELECT person_id, movie_id, position, job FROM has_position WHERE job IS NOT NULL',
    'plays_role':   'SELECT person_id, movie_id, role FROM plays_role',
}

# Copied from the locations directory
LOCATION_RELATIONS = ['places', 'located_in', 'filmed_at']


def format_value(value):
    if isinstance(value, float):
        return repr(value)  # shortest form that reads back as the same number: 8.2, not 8.20000
    text = str(value)
    if any(ch in text for ch in '\t\n\r\\'):
        sys.exit('cannot write %r to a fact file: it contains a tab, newline or backslash' % text)
    return text


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    database, locations, outdir = sys.argv[1], sys.argv[2], sys.argv[3]
    os.makedirs(outdir, exist_ok=True)
    connection = duckdb.connect(database, read_only=True)
    for relation, query in RELATIONS.items():
        rows = connection.execute(query + ' ORDER BY ALL').fetchall()
        with open(os.path.join(outdir, relation + '.facts'), 'w', encoding='utf-8') as out:
            for row in rows:
                out.write('\t'.join(format_value(v) for v in row) + '\n')
        print('  %-14s %8d facts' % (relation, len(rows)))
    movie_ids = {row[0] for row in connection.execute('SELECT movie_id FROM movies').fetchall()}
    connection.close()
    for relation in LOCATION_RELATIONS:
        with open(os.path.join(locations, relation + '.facts'), encoding='utf-8') as f:
            lines = f.readlines()
        if relation == 'filmed_at':
            kept = [line for line in lines if line.split('\t')[0] in movie_ids]
            if len(kept) < len(lines):
                print('  (left out %d filming locations of movies not in %s)' % (len(lines) - len(kept), database))
            lines = kept
        with open(os.path.join(outdir, relation + '.facts'), 'w', encoding='utf-8') as out:
            out.writelines(lines)
        print('  %-14s %8d facts' % (relation, len(lines)))
    print('%s -> %s' % (database, outdir))


if __name__ == '__main__':
    main()
