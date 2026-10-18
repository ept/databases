// Traverse's WebAssembly engine (npm @truespar/traverse-wasm), set up to run under Node.
//
// The package is meant for browsers, where it is the engine of the app at
// https://traverse.truespar.com/. Under Node it needs two stand-ins for browser globals: the
// rayon thread pool's helper module registers a message listener on `self` when it is
// imported, and the engine's clock (the web-time crate) reads `self.performance`. We never
// start the thread pool, so queries run on the calling thread.
//
// Used by traverse-import.mjs (to build the .tvdb) and traverse-query.mjs (to run examples).

import { readFileSync } from 'node:fs'

globalThis.self = { addEventListener() {}, removeEventListener() {}, performance: globalThis.performance }

const wasm = await import('@truespar/traverse-wasm/pkg/traverse_wasm.js')
wasm.initSync({ module: readFileSync(new URL(import.meta.resolve('@truespar/traverse-wasm/pkg/traverse_wasm_bg.wasm'))) })

export const { TraverseDb } = wasm
