#!/usr/bin/env python3
"""Fetch the filming locations of the movies from Wikidata, with the places that contain them.

Usage:  python3 locations/fetch.py moviedb-2025/movies.duckdb locations/wikidata.json

Looks up every movie in the database on Wikidata by its IMDb ID (property P345), and
fetches its filming locations (P915). Then, starting from those places, it follows three
properties upwards until nothing new turns up:

    P131  located in the administrative territorial entity
    P17   country
    P30   continent

It also fetches each place's English label (or, failing that, its label in "mul", the
code Wikidata uses for a name that is the same in many languages), and whether it has a dissolution date
(P576). The result is a raw snapshot, which locations/clean.py turns into fact files.
Deprecated statements, and statements with an end time (P582), such as a town's
membership of a district that was abolished in 1974, are left out here; the snapshot
keeps each statement's rank, preferred or normal, for clean.py to choose between.

Wikidata's data is CC0 (public domain). See locations/README.md for how to refresh it.
"""

import datetime
import json
import sys
import time
import urllib.parse
import urllib.request

import duckdb

ENDPOINT = 'https://query.wikidata.org/sparql'
# Wikidata asks for a descriptive User-Agent: https://meta.wikimedia.org/wiki/User-Agent_policy
USER_AGENT = 'databases-course-locations/1.0 (University of Cambridge teaching materials)'
BATCH = 150  # items per query; much more than this, and queries start to time out


def sparql(query):
    data = urllib.parse.urlencode({'query': query, 'format': 'json'}).encode()
    for attempt in range(5):
        request = urllib.request.Request(ENDPOINT, data=data, headers={
            'User-Agent': USER_AGENT, 'Accept': 'application/sparql-results+json'})
        try:
            with urllib.request.urlopen(request, timeout=120) as response:
                result = json.load(response)['results']['bindings']
            time.sleep(1)  # be gentle with the public endpoint
            return result
        except Exception as e:  # timeouts and HTTP 429/5xx are common; retry with backoff
            print('  query failed (%s), retrying' % e, file=sys.stderr)
            time.sleep(10 * (attempt + 1))
    sys.exit('Wikidata query failed five times; giving up')


def qid(binding):
    return binding['value'].rsplit('/', 1)[-1]


def batches(items):
    items = sorted(items)
    for i in range(0, len(items), BATCH):
        yield items[i:i + BATCH]


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__.strip().splitlines()[2].strip())
    database, output = sys.argv[1], sys.argv[2]
    connection = duckdb.connect(database, read_only=True)
    movie_ids = [row[0] for row in connection.execute('SELECT movie_id FROM movies').fetchall()]
    connection.close()

    filmed_at = set()
    for batch in batches(movie_ids):
        values = ' '.join('"%s"' % m for m in batch)
        for row in sparql('''
                SELECT ?imdb ?place WHERE {
                  VALUES ?imdb { %s }
                  ?movie wdt:P345 ?imdb; p:P915 ?st .
                  ?st ps:P915 ?place; wikibase:rank ?rank .
                  FILTER(?rank != wikibase:DeprecatedRank && isIRI(?place))
                }''' % values):
            filmed_at.add((row['imdb']['value'], qid(row['place'])))
    print('%d filming locations of %d movies' % (len(filmed_at), len({m for m, _ in filmed_at})),
          file=sys.stderr)

    statements = set()
    seen, frontier = set(), {p for _, p in filmed_at}
    while frontier:
        seen |= frontier
        found = set()
        for batch in batches(frontier):
            values = ' '.join('wd:' + q for q in batch)
            for row in sparql('''
                    SELECT ?x ?prop ?y ?rank WHERE {
                      VALUES ?x { %s }
                      VALUES (?prop ?p ?ps) { ("P131" p:P131 ps:P131) ("P17" p:P17 ps:P17)
                                              ("P30" p:P30 ps:P30) }
                      ?x ?p ?st . ?st ?ps ?y; wikibase:rank ?rank .
                      FILTER(?rank != wikibase:DeprecatedRank && isIRI(?y))
                      FILTER NOT EXISTS { ?st pq:P582 [] }
                    }''' % values):
                rank = 'preferred' if row['rank']['value'].endswith('PreferredRank') else 'normal'
                statements.add((qid(row['x']), row['prop']['value'], qid(row['y']), rank))
                found.add(qid(row['y']))
        frontier = found - seen
        print('%d places so far' % len(seen), file=sys.stderr)

    labels, dissolved = {}, set()
    for batch in batches(seen):
        values = ' '.join('wd:' + q for q in batch)
        for row in sparql('''
                SELECT ?x ?label WHERE {
                  VALUES ?x { %s }
                  ?x rdfs:label ?label . FILTER(lang(?label) IN ("en", "mul"))
                }
                ORDER BY DESC(lang(?label))''' % values):  # mul first, so that en overrides it
            labels[qid(row['x'])] = row['label']['value']
        for row in sparql('SELECT DISTINCT ?x WHERE { VALUES ?x { %s } ?x wdt:P576 [] }' % values):
            dissolved.add(qid(row['x']))

    snapshot = {
        'source': 'Wikidata (https://www.wikidata.org/), CC0; fetched by locations/fetch.py',
        'fetched': datetime.date.today().isoformat(),
        'filmed_at': sorted(filmed_at),
        'statements': sorted(statements),
        'labels': dict(sorted(labels.items())),
        'dissolved': sorted(dissolved),
    }
    # One entry per line, so that a refresh gives a readable diff
    with open(output, 'w', encoding='utf-8') as out:
        out.write('{\n')
        for i, (key, value) in enumerate(snapshot.items()):
            out.write('%s: ' % json.dumps(key))
            if isinstance(value, list):
                out.write('[\n' + ',\n'.join('  ' + json.dumps(v, ensure_ascii=False) for v in value) + '\n]')
            elif isinstance(value, dict):
                out.write('{\n' + ',\n'.join('  %s: %s' % (json.dumps(k), json.dumps(v, ensure_ascii=False))
                                             for k, v in value.items()) + '\n}')
            else:
                out.write(json.dumps(value))
            out.write(',\n' if i < len(snapshot) - 1 else '\n')
        out.write('}\n')
    print('%d places, %d statements -> %s' % (len(seen), len(statements), output), file=sys.stderr)


if __name__ == '__main__':
    main()
