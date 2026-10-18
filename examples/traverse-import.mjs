#!/usr/bin/env node
// Build a Traverse graph database (.tvdb) from the TinyDB export of the example database.
//
// Usage:  node examples/traverse-import.mjs moviedb-2025/movies.tinydb.json moviedb-2025/movies.tvdb
//
// Traverse (https://truespar.com/traverse) is a graph database with a Cypher dialect close to
// Neo4j's. The graph is the one that moviedb-generator/make_databases.py loads into Neo4j:
//
//   (:Movie {movie_id, title, type, year, minutes, genres, rating, rating_votes})
//   (:Person {person_id, name, birthyear, deathyear})
//   (:Person)-[:ACTED_IN {roles}]->(:Movie)
//   (:Person)-[:DIRECTED|PRODUCED|WROTE|COMPOSED_FOR {job}]->(:Movie)
//
// with the same constraints and indexes. A property whose value is unknown is absent, as in
// Neo4j, where storing null removes the property. The input is the TinyDB export rather than
// the relational database because it keeps the order of each actor's roles, which the
// generator passes to Neo4j and the relational schema loses.
//
// The database is built with Traverse's WebAssembly engine (see traverse-engine.mjs), which
// is the engine of the browser app at https://traverse.truespar.com/, so students can upload
// the resulting file there. Its native counterpart, `traverse-admin cypher-import`, is
// released only for x86-64 Linux and Windows, whereas this runs anywhere Node does.

import { readFileSync, writeFileSync, rmSync } from 'node:fs'
import { TraverseDb } from './traverse-engine.mjs'

// The arrays of a movie document that become relationships, and their relationship types.
const CREDITS = [
  ['actors', 'ACTED_IN', 'roles'],
  ['directors', 'DIRECTED', 'job'],
  ['producers', 'PRODUCED', 'job'],
  ['writers', 'WROTE', 'job'],
  ['composers', 'COMPOSED_FOR', 'job'],
]

const BATCH = 5000  // rows per UNWIND, to bound the size of each query's parameters

function main() {
  const [source, target] = process.argv.slice(2)
  if (!source || !target) {
    console.error('Usage: node examples/traverse-import.mjs <movies.tinydb.json> <movies.tvdb>')
    process.exit(1)
  }
  const documents = JSON.parse(readFileSync(source, 'utf8'))
  const movies = Object.values(documents.movies)
  const people = Object.values(documents.people)

  const db = new TraverseDb()
  const run = (cypher, params = null) => db.query(cypher, params)
  const runBatched = (cypher, rows) => {
    for (let i = 0; i < rows.length; i += BATCH) run(cypher, { rows: rows.slice(i, i + BATCH) })
  }

  // As in make_databases.py. The uniqueness constraints also index the IDs, which the
  // MATCHes that create the relationships rely on.
  run('CREATE CONSTRAINT movie_id_unique FOR (m:Movie) REQUIRE m.movie_id IS UNIQUE')
  run('CREATE CONSTRAINT person_id_unique FOR (p:Person) REQUIRE p.person_id IS UNIQUE')
  run('CREATE INDEX movie_titles FOR (m:Movie) ON (m.title)')
  run('CREATE INDEX person_names FOR (p:Person) ON (p.name)')

  // Missing keys become null parameters, and a null property is not stored.
  runBatched(`
    UNWIND $rows AS movie
    CREATE (:Movie {
      movie_id: movie.movie_id, title: movie.title, type: movie.type, year: movie.year,
      minutes: movie.minutes, genres: movie.genres,
      rating: movie.rating, rating_votes: movie.rating_votes
    })`, movies)
  runBatched(`
    UNWIND $rows AS person
    CREATE (:Person {
      person_id: person.person_id, name: person.name,
      birthyear: person.birthyear, deathyear: person.deathyear
    })`, people)

  const counts = { Movie: movies.length, Person: people.length }
  for (const [key, type, property] of CREDITS) {
    const rows = movies.flatMap((m) => (m[key] || []).map((credit) => ({
      movie_id: m.movie_id, person_id: credit.person_id, value: credit[property] ?? null,
    })))
    runBatched(`
      UNWIND $rows AS credit
      MATCH (p:Person {person_id: credit.person_id})
      MATCH (m:Movie {movie_id: credit.movie_id})
      CREATE (p)-[:${type} {${property}: credit.value}]->(m)`, rows)
    counts[type] = rows.length
  }

  // Check that every node and relationship arrived: a credit whose person or movie could
  // not be matched would silently create nothing.
  const actual = (pattern) => run(`MATCH ${pattern} RETURN count(*) AS n`).rows[0][0]
  for (const [name, expected] of Object.entries(counts)) {
    const n = actual(name === 'Movie' || name === 'Person' ? `(:${name})` : `()-[:${name}]->()`)
    console.log('  %s %d', name.padEnd(14), n)
    if (n !== expected) throw new Error(`${name}: expected ${expected}, found ${n}`)
  }

  rmSync(target, { force: true })
  writeFileSync(target, db.exportTvdb())
  console.log('%s -> %s (Traverse %s)', source, target, TraverseDb.version())
}

main()
