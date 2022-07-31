import { Actions, Biscuit, Message, StatusTypes } from "@biscuitland/core"
import { ActivityTypes, GatewayIntents } from "@biscuitland/api-types"
import { attachments, commands } from "./cache.js"
import { load } from "./handle-commands.js"
import Fastify from "fastify"
import "dotenv/config"
import "./util/polyfill.js"

PREFIX = "%%"

files = new Set
files.add file for await file from load "#{process.cwd()}/dist/commands", console.debug

intents = GatewayIntents.Guilds | GatewayIntents.GuildMessages | GatewayIntents.MessageContent
session = new Biscuit token: process.env.GW_AUTH, intents: intents

artificialReady = ->
    toSend = for command from commands.values() then {
        name: command.name
        description: command.description
    }

    session.upsertApplicationCommands toSend

    activities = [
        name: "toasts 🍞"
        type: ActivityTypes.Listening
        createdAt: Date.now()
    ]

    for shard from session.ws.agent.shards.values()
        session.editStatus shard.id, status: StatusTypes.online, activities: activities

session.events.on "guildCreate", (guild) ->
    channelId = "1002076190422614056"

    Message::reply.call { session: session, channelId: channelId }, {
        content: "Hey I just joined #{guild}!"
    }

session.events.on "interactionCreate", (interaction) ->
    if interaction.isCommand()
        command = commands.get interaction.commandName
        command?.execute session: session, context: interaction

removeAccents = (str) -> str.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase()

session.events.on "messageCreate", (message) ->
    # que-so bot
    plainContent = removeAccents message.content

    console.log "content: %s", plainContent

    if plainContent.endsWith "que"
        message.reply content: "so", messageReference: messageId: message.id

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

# "web" server!

app = Fastify {}
app.all "*", (req, reply) ->
    if req.method isnt "POST"
        return req.reply(
            new Response JSON.stringify { error: "Method not allowed." }, { status: 405 }
        )

    json = JSON.parse req.body

    Actions.raw session, json.shardId, json.data

    unless json.data.t or json.data.d then return

    Actions[json.data.t]? session, json.shardId, json.data.d

    req.reply(
        new Response undefined, status: 204
    )

await app.listen port: process.env.GW_PORT
await artificialReady

# do session.start
