import { Biscuit, StatusTypes } from "@biscuitland/core"
import { ActivityTypes, GatewayIntents } from "@biscuitland/api-types"
import { config } from "dotenv"
import { commands } from "./cache.js"
import { load } from "./handle-commands.js"

PREFIX ="~"

_files = []

for await file from load "#{process.cwd()}/dist/commands", console.debug
    _files.push file

config debug: on

intents = GatewayIntents.Guilds | GatewayIntents.GuildMessages | GatewayIntents.MessageContent
session = new Biscuit token: process.env.TOKEN, intents: intents

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
    if message.author?.bot
        return

    if not message.content.startsWith PREFIX
        return

    args = message.content.substring(PREFIX.length).trim().split /\s+/gm
    name = args.shift()?.toLowerCase()

    command = commands.get name
    command?.execute session: session, context: message

do session.start
