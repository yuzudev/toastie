import { createCommand } from "../create-command.js"

createCommand {
    name: "ping"
    execute: ({ session, context }) -> context.reply content: "pong!"
}
