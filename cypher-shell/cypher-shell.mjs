#!/usr/bin/env node
// A command-line shell for running Cypher queries against a Traverse graph database.
//
// Usage:  node cypher-shell.mjs movies.tvdb               interactive shell
//         node cypher-shell.mjs movies.tvdb queries.cypher  run the queries in a file
//         node cypher-shell.mjs movies.tvdb < queries.cypher
//
// It runs Traverse's WebAssembly engine (npm @truespar/traverse-wasm), the same engine as
// the browser app at https://traverse.truespar.com/, so queries behave the same in both.
// The database is loaded into memory; changes made with CREATE, SET, DELETE, etc. last
// until the shell exits, and are not written back to the file unless you use :save.
// See README.md for instructions.

import { readFileSync, writeFileSync } from 'node:fs'
import { createRequire } from 'node:module'
import readline from 'node:readline'

// The package is meant for browsers. Under Node it needs two stand-ins for browser
// globals: the rayon thread pool's helper module registers a message listener on `self`
// when it is imported, and the engine's clock reads `self.performance`. The thread pool is
// never started, so queries run single-threaded.
globalThis.self = { addEventListener() {}, removeEventListener() {}, performance: globalThis.performance }
const require = createRequire(import.meta.url)
const wasm = await import('@truespar/traverse-wasm/pkg/traverse_wasm.js')
wasm.initSync({ module: readFileSync(require.resolve('@truespar/traverse-wasm/pkg/traverse_wasm_bg.wasm')) })

const MAX_ROWS = 40  // rows printed per result; :rows changes it

// In a terminal, a value too wide for the window is truncated with an ellipsis; output to
// a file or a pipe is never truncated.
const maxCellWidth = () => process.stdout.isTTY ? Math.max(20, (process.stdout.columns || 100) - 4) : Infinity

const HELP = `Enter a Cypher query, ending with a semicolon; it may span several lines.
Shell commands:
  :help              show this message
  :schema            list the labels, relationship types, and property keys
  :rows N            print at most N rows of each result (currently ${MAX_ROWS})
  :save FILE.tvdb    write the database, including your changes, to a file
  :quit              exit (or press Ctrl-D)
Ctrl-C discards a partly typed query. While a query is running, Ctrl-C exits the shell
(the engine has no way of cancelling a query part-way).`

// ---- Formatting results ----

function formatProps(props) {
  const entries = Object.entries(props ?? {})
  if (entries.length === 0) return ''
  return ' {' + entries.map(([k, v]) => `${k}: ${formatValue(v, true)}`).join(', ') + '}'
}

function formatValue(value, nested = false) {
  if (value === null || value === undefined) return nested ? 'null' : 'NULL'
  if (Array.isArray(value)) return '[' + value.map((v) => formatValue(v, true)).join(', ') + ']'
  if (typeof value === 'string') return nested ? `'${value}'` : value
  if (typeof value === 'object') {
    switch (value._type) {
      case 'node':
        return '(' + value.labels.map((l) => ':' + l).join('') + formatProps(value.properties) + ')'
      case 'edge':
        return '[:' + value.type + formatProps(value.properties) + ']'
      case 'path': {
        // Show each edge with an arrow in the direction it actually points.
        let text = formatValue(value.nodes[0], true)
        for (let i = 0; i < value.edges.length; i++) {
          const edge = value.edges[i]
          const forward = edge.source === value.nodes[i].id
          const e = formatValue(edge, true)
          text += (forward ? `-${e}->` : `<-${e}-`) + formatValue(value.nodes[i + 1], true)
        }
        return text
      }
      default:
        return '{' + Object.entries(value).map(([k, v]) => `${k}: ${formatValue(v, true)}`).join(', ') + '}'
    }
  }
  return String(value)
}

function truncate(text, width) {
  return text.length <= width ? text : text.slice(0, width - 1) + '…'
}

function printTable(columns, rows, maxRows) {
  const shown = rows.slice(0, maxRows)
  const cells = shown.map((row) => row.map((v) => truncate(formatValue(v), maxCellWidth())))
  const numeric = columns.map((_, i) => shown.length > 0 && shown.every((r) => r[i] === null || typeof r[i] === 'number'))
  const widths = columns.map((c, i) => Math.max(c.length, ...cells.map((r) => r[i].length)))
  const line = (l, m, r) => l + widths.map((w) => '─'.repeat(w + 2)).join(m) + r
  const row = (vals) => '│' + vals.map((v, i) => ' ' + (numeric[i] ? v.padStart(widths[i]) : v.padEnd(widths[i])) + ' ').join('│') + '│'
  console.log(line('┌', '┬', '┐'))
  console.log(row(columns))
  console.log(line('├', '┼', '┤'))
  for (const r of cells) console.log(row(r))
  console.log(line('└', '┴', '┘'))
  const more = rows.length > shown.length ? ` (showing the first ${shown.length})` : ''
  console.log(`${rows.length} row${rows.length === 1 ? '' : 's'}${more}`)
}

function printStats(stats) {
  const changes = Object.entries(stats ?? {}).filter(([, n]) => n > 0)
  if (changes.length > 0) console.log(changes.map(([k, n]) => `${k.replaceAll('_', ' ')}: ${n}`).join(', '))
}

// ---- Running queries and commands ----

function runQuery(db, cypher, settings) {
  const start = performance.now()
  try {
    const result = db.query(cypher, null)
    const ms = performance.now() - start
    if (result.columns.length > 0) printTable(result.columns, result.rows, settings.maxRows)
    printStats(result.stats)
    console.log(`(${ms < 1000 ? ms.toFixed(0) + ' ms' : (ms / 1000).toFixed(1) + ' s'})`)
    return true
  } catch (err) {
    console.error('Error: ' + String(err.message ?? err))
    return false
  }
}

function runCommand(db, command, settings) {
  const [name, arg] = command.trim().split(/\s+/, 2)
  switch (name) {
    case ':help': console.log(HELP); break
    case ':quit': case ':exit': process.exit(0)
    case ':schema': {
      const s = db.schema()
      console.log('Labels:             ' + s.labels.join(', '))
      console.log('Relationship types: ' + s.relationship_types.join(', '))
      console.log('Property keys:      ' + s.property_keys.map((p) => p.name).join(', '))
      break
    }
    case ':rows':
      if (/^\d+$/.test(arg ?? '')) settings.maxRows = Number(arg)
      else console.error('Usage: :rows N')
      break
    case ':save':
      if (!arg) { console.error('Usage: :save FILE.tvdb'); break }
      writeFileSync(arg, db.exportTvdb())
      console.log(`Saved to ${arg}`)
      break
    default:
      console.error(`Unknown command ${name}; enter :help for a list`)
  }
}

// Splits text into statements at semicolons that are not inside a string or comment, and
// returns them with whatever incomplete statement is left over at the end.
function splitStatements(text) {
  const statements = []
  let current = '', quote = null, i = 0
  while (i < text.length) {
    const c = text[i]
    if (quote) {
      current += c
      if (c === '\\') { current += text[i + 1] ?? ''; i += 2; continue }
      if (c === quote) quote = null
    } else if (c === "'" || c === '"' || c === '`') {
      quote = c; current += c
    } else if (c === '/' && text[i + 1] === '/') {
      const end = text.indexOf('\n', i)
      i = end < 0 ? text.length : end
      continue
    } else if (c === ';') {
      if (current.trim()) statements.push(current.trim())
      current = ''
    } else {
      current += c
    }
    i++
  }
  return { statements, rest: current }
}

// ---- Main ----

const [databaseFile, queryFile] = process.argv.slice(2)
if (!databaseFile) {
  console.error('Usage: node cypher-shell.mjs <database.tvdb> [queries.cypher]')
  process.exit(1)
}
const db = new wasm.TraverseDb()
try {
  db.loadTvdb(readFileSync(databaseFile))
} catch (err) {
  console.error(`Could not load ${databaseFile}: ${err.message ?? err}`)
  process.exit(1)
}
const settings = { maxRows: MAX_ROWS }

if (queryFile || !process.stdin.isTTY) {
  // Batch mode: run every statement in the file (or standard input), then exit. The exit
  // status is 1 if any statement failed.
  const text = readFileSync(queryFile ?? 0, 'utf8')
  const { statements, rest } = splitStatements(text)
  if (rest.trim()) statements.push(rest.trim())
  let ok = true
  for (const statement of statements) {
    if (statement.startsWith(':')) { runCommand(db, statement, settings); continue }
    console.log('\n' + statement)
    ok = runQuery(db, statement, settings) && ok
  }
  process.exit(ok ? 0 : 1)
}

console.log(`Traverse ${wasm.TraverseDb.version()}: ${databaseFile} has ${db.nodeCount()} nodes ` +
            `and ${db.edgeCount()} relationships.`)
console.log('Enter :help for help. Changes are lost on exit unless you use :save.')
const rl = readline.createInterface({ input: process.stdin, output: process.stdout, prompt: 'cypher> ' })
let buffer = ''
rl.prompt()
rl.on('line', (line) => {
  if (!buffer && line.trim().startsWith(':')) {
    runCommand(db, line, settings)
  } else {
    const { statements, rest } = splitStatements(buffer + line + '\n')
    // Queries run synchronously, so the terminal's raw mode (in which readline reads Ctrl-C
    // as a keypress) is switched off while they run: Ctrl-C then sends SIGINT, which has
    // no handler here, and so ends the process.
    if (statements.length > 0) process.stdin.setRawMode(false)
    for (const statement of statements) runQuery(db, statement, settings)
    if (statements.length > 0) process.stdin.setRawMode(true)
    buffer = rest.trim() ? rest : ''
  }
  rl.setPrompt(buffer ? '    ...> ' : 'cypher> ')
  rl.prompt()
})
rl.on('SIGINT', () => {
  if (buffer) { buffer = ''; console.log(); rl.setPrompt('cypher> '); rl.prompt() }
  else rl.close()
})
rl.on('close', () => { console.log(); process.exit(0) })
