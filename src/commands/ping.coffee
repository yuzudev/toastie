import { Message } from "@biscuitland/core"
import { createCommand } from "../create-command.js"

createCommand {
    name: "ping"
    description: "pong!"
    execute: ({ session, context }) ->
        if context instanceof Message
            context.reply content: "pong!"
        else
            context.respond with: content: "ping"
}
