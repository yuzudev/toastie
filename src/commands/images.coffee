import { Message } from "@biscuitland/core"
import { Image } from "imagescript"
import { createCommand } from "../create-command.js"
import { attachments } from "../cache.js"

SPEECH_BALLOON_URL = "https://i.redd.it/z0nqjst12ih61.jpg"

createCommand {
    name: "speech-balloon"
    description: "n128 sucks"
    execute: ({ session, context }) ->
        if context instanceof Message
            balloonImage = await fetch SPEECH_BALLOON_URL
                .then (img) -> img.arrayBuffer()
                .then Image.decode

            attachmentUrl = attachments.get(context.channelId)?[0]

            if not attachments.has context.channelId or not attachmentUrl
                context.reply content: "Image not found in channel"
                return

            i = await fetch attachmentUrl
                .then (img) -> img.arrayBuffer()
                .then Image.decode

            i.fit i.width, i.height + (balloonImage.height - 100) * 2
            i.composite (balloonImage.resize i.width, balloonImage.height - 100), 0, 0
            i.crop 0, 0, i.width, i.height - balloonImage.height

            buffer = await i.encode().then (i) -> i.buffer
            blob = new Blob [Buffer.from buffer, "base64"]

            context.reply {
                content: context.author.username
                files: [{ blob: blob, name: "img.png" }]
            }
}
