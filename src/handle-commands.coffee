import fs from "node:fs"

export load = (path) ->
    filenames = await fs.promises.readdir path
    yield from filenames.map (s) -> import("#{path}/#{s}")

export loadFromCWD = (relativePath) ->
    load "#{process.cwd()}#{relativePath}"
