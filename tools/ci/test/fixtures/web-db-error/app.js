indexedDB.open('wio', 1);
setTimeout(() => console.error('drift worker failed: could not load sqlite3.wasm'), 300);
