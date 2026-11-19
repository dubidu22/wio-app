setTimeout(async () => {
  const root = await navigator.storage.getDirectory();
  const dir = await root.getDirectoryHandle('drift_db', { create: true });
  await dir.getFileHandle('wio', { create: true });
}, 300);
