import fs from "node:fs"

export load = (path, logFn) ->
    filenames = await fs.promises.readdir path
    for fname in filenames
        if fs.lstatSync("#{path}/#{fname}").isDirectory()
            load "#{path}/#{fname}"

        logFn? fname
        yield import("#{path}/#{fname}")
