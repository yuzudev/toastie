import { Actions, Biscuit, Message, StatusTypes } from "@biscuitland/core"
import { ActivityTypes, GatewayIntents } from "@biscuitland/api-types"
import { DefaultRestAdapter } from "@biscuitland/rest"
import { attachments, commands } from "./cache.js"
import { load } from "./handle-commands.js"

import Fastify from "fastify"

import "dotenv/config"
import "./util/polyfill.js"

{ PREFIX } = process.env

files = new Set
files.add file for await file from load "#{process.cwd()}/dist/commands", console.debug

session = new Biscuit {
    token: process.env.GW_AUTH
    rest: {
        adapter: DefaultRestAdapter
        options: url: "http://localhost:#{process.env.REST_PORT}"
    }
}

artificialReady = ->
    toSend = for command from commands.values() then {
        name: command.name
        description: command.description
    }

    session.upsertApplicationCommands toSend

    ### TODO: open an endpoint to update the presence
    activities = [
        name: "toasts 🍞"
        type: ActivityTypes.Listening
        createdAt: Date.now()
    ]

    for shard from session.ws.agent.shards.values()
        session.editStatus shard.id, status: StatusTypes.online, activities: activities
    ###

session.events.on "guildCreate", (guild) ->

    # TODO: move this to some constant!
    channelId = "1002076190422614056"

    # Usual way to send a message to a channel by looking at the id
    Message::reply.call { session: session, channelId: channelId }, {
        content: "Hey I just joined #{guild}!"
    }

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

app = new WebSocketServer {
    port: Number.parseInt process.env.WS_PORT
}

textDecoder = new TextDecoder()

app.on "connection", (ws) ->
    ws.on "message", (uint ### buffer or array buffer ###) ->
        decompressable = new Uint8Array uint
        data = JSON.parse textDecoder.decode decompressable

        Actions["raw"] session, data.id, data.payload

        return if not data.payload.t or not data.payload.d

        Actions[data.payload.t]? session, data.id, data.payload.d

### We don't have to start the bot since it's already running
do session.start
###
