import { Biscuit, StatusTypes } from "@biscuitland/core"
import { ActivityTypes, GatewayIntents } from "@biscuitland/api-types"
import { config } from "dotenv"
import { attachments, commands } from "./cache.js"
import { load } from "./handle-commands.js"

# POLYFILLS

if not globalThis.Blob
    await import("node:buffer").then ({ Blob }) -> globalThis.Blob = Blob

# END POLYFILLS

PREFIX = "%"

_files = []

for await file from load "#{process.cwd()}/dist/commands", console.debug
    _files.push file

config debug: on

intents = GatewayIntents.Guilds | GatewayIntents.GuildMessages | GatewayIntents.MessageContent
session = new Biscuit token: process.env.TOASTIE_TOKEN, intents: intents

session.events.on "ready", (ready) ->
    toSend = for command from commands.values() then {
        name: command.name
        description: command.description
    }

    session.upsertApplicationCommands toSend

    console.log "Logged in as %s!!", ready.user.username

    activities = [
        name: "toasts 🍞"
        type: ActivityTypes.Listening
        createdAt: Date.now()
    ]

    for shard from session.ws.agent.shards.values()
        session.editStatus shard.id, status: StatusTypes.online, activities: activities

session.events.on "interactionCreate", (interaction) ->
    if interaction.isCommand()
        command = commands.get interaction.commandName
        command?.execute session: session, context: interaction

session.events.on "messageCreate", (message) ->
    # attachments
    if message.attachments.length > 0
        attachments.set message.channelId, message.attachments.map (att) -> att.attachment

    if message.embeds.length > 0
        attachments.set message.channelId, message.embeds.map (em) -> em.image.url

    # commands
    if message.author?.bot
        return

    if not message.content.startsWith PREFIX
        return

    args = message.content.substring(PREFIX.length).trim().split /\s+/gm
    name = args.shift()?.toLowerCase()

    command = commands.get name
    command?.execute session: session, context: message

do session.start
