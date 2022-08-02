###
Polyfills to run on prod since my vps uses ubuntu 16
###

if not globalThis.Blob
    await import("node:buffer").then ({ Blob }) -> globalThis.Blob = Blob

if not globalThis.fetch
    console.warn "Please use node18"
    await import("node-fetch").then (Fetch) -> globalThis.fetch = Fetch
