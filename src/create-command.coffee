import { commands } from "./cache.js"

export createCommand = (cmd) ->
    commands.set cmd.name, cmd
