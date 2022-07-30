import { Biscuit, StatusTypes } from "@biscuitland/core"
import { ActivityTypes, GatewayIntents } from "@biscuitland/api-types"
import { config } from "dotenv"

config debug: on

intents = GatewayIntents.Guilds | GatewayIntents.GuildMessages | GatewayIntents.MessageContent
session = new Biscuit token: process.env.TOKEN, intents: intents

session.events.on "ready", (ready) ->
    console.log "Logged in as %s!!", ready.user.username

    activities = [
        name: "toasts 🍞"
        type: ActivityTypes.Listening
        createdAt: Date.now()
    ]

    for shard from session.ws.agent.shards.values()
        session.editStatus shard.id, status: StatusTypes.online, activities: activities

session.events.on "messageCreate", (message) ->
    if message.content.startsWith "!ping" then message.reply content: "pong!"

do session.start
