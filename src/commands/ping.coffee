import { commands } from "../cache.js"

commands.set "ping", {
    name: "ping",
    execute: ({ session, context }) ->
        context.reply content: "pong!"
}
