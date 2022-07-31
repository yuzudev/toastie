

if not globalThis.Blob
    await import("node:buffer").then ({ Blob }) -> globalThis.Blob = Blob

