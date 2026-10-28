#!/usr/bin/env python3
"""Make a copy of the relational database with the filming locations added.

Usage:  python3 examples/duckdb-add-locations.py moviedb-2025/movies.duckdb locations moviedb-2025/movies-locations.duckdb

Copies the database and adds three tables from the fact files in the locations directory
(see locations/README.md), with the same names and columns as the Datalog relations:

    places(place_id, name)
    located_in(place_id, parent_id)
    filmed_at(movie_id, place_id)

This version of the database is only for the lecture notes, so that the recursive queries
on the slides can be run in SQL and compared with Datalog; the database that students
download (playground-sql/) does not have these tables. Filming locations of movies that are
not in the database are left out, as in examples/souffle-export.py.
"""

import os
import shutil
import sys

import duckdb

SCHEMA = '''
CREATE TABLE places (
    place_id  VARCHAR PRIMARY KEY,
    name      VARCHAR NOT NULL
);
CREATE TABLE located_in (
    place_id  VARCHAR REFERENCES places(place_id),
    parent_id VARCHAR REFERENCES places(place_id),
    PRIMARY KEY (place_id, parent_id)
);
CREATE TABLE filmed_at (
    movie_id  VARCHAR REFERENCES movies(movie_id),
    place_id  VARCHAR REFERENCES places(place_id),
    PRIMARY KEY (movie_id, place_id)
);
'''


def read_facts(path):
    with open(path, encoding='utf-8') as f:
        return [tuple(line.rstrip('\n').split('\t')) for line in f]


def main():
    if len(sys.argv) != 4:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    source, locations, target = sys.argv[1], sys.argv[2], sys.argv[3]
    if os.path.exists(target):
        os.remove(target)
    shutil.copyfile(source, target)
    connection = duckdb.connect(target)
    try:
        connection.execute(SCHEMA)
        movie_ids = {row[0] for row in connection.execute('SELECT movie_id FROM movies').fetchall()}
        for table in ['places', 'located_in', 'filmed_at']:
            rows = read_facts(os.path.join(locations, table + '.facts'))
            if table == 'filmed_at':
                rows = [row for row in rows if row[0] in movie_ids]
            connection.executemany('INSERT INTO %s VALUES (?, ?)' % table, rows)
            print('  %-14s %8d rows' % (table, len(rows)))
    except duckdb.Error as error:
        connection.close()
        os.remove(target)
        sys.exit('%s: %s' % (target, error))
    connection.close()
    print('%s + %s -> %s' % (source, locations, target))


if __name__ == '__main__':
    main()
