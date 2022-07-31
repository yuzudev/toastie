
import { Message } from "@biscuitland/core"
import { createCommand } from "../create-command.js"

mb = (v) -> "#{(((v / 1024 / 1024) * 100) / 100).toFixed 1}mb"

createCommand {
    name: "memory"
    description: "memory consumption"
    execute: ({ session, context }) ->
        usage = do process.memoryUsage

        mem = """
            **rss:** #{mb usage.rss}
            **heap:** #{mb usage.heapTotal}
            **heap used:** #{mb usage.heapUsed}
        """

        if context instanceof Message
            context.reply content: mem
        else
            context.respond with: content: mem
}
