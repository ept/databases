#!/usr/bin/env node
// Run one Cypher query against a Traverse database and print the result as JSON.
//
// Usage:  node examples/traverse-query.mjs moviedb-2025/movies.tvdb examples/graph-foo.cypher
//
// Prints {"columns": [...], "rows": [[...], ...]} on stdout. examples/render.py calls this for
// query files ending in .cypher, and formats the result exactly as it does for SQL. A query
// that fails prints the error on stderr and exits with status 1.

import { readFileSync } from 'node:fs'
import { TraverseDb } from './traverse-engine.mjs'

const TIMEOUT_MS = 10 * 60 * 1000  // the all-shortest-paths query takes about a minute

const [database, queryFile] = process.argv.slice(2)
if (!database || !queryFile) {
  console.error('Usage: node examples/traverse-query.mjs <database.tvdb> <query.cypher>')
  process.exit(1)
}
const db = new TraverseDb()
db.loadTvdb(readFileSync(database))
try {
  const result = db.query(readFileSync(queryFile, 'utf8'), null, TIMEOUT_MS)
  console.log(JSON.stringify({ columns: result.columns, rows: result.rows }))
} catch (err) {
  console.error(String(err.message ?? err))
  process.exit(1)
}
