###
Standalone gateway process
###

import "dotenv/config"

import { GatewayIntents } from "@biscuitland/api-types"
import { DefaultRestAdapter } from "@biscuitland/rest"
import { ShardManager } from "@biscuitland/ws"

import WebSocket from "ws"

rest = new DefaultRestAdapter {
    token: process.env.GW_AUTH
}

hb = undefined
ws = undefined

ask = ->
    ws = new WebSocket("ws://localhost:#{process.env.WS_PORT}")
        .on "error", ->
            ws?.close()

        .on "close", ->
            unless hb then hb = setInterval (() -> ask()), 10000

        .on "open", ->
            clearInterval(hb)
            hb = undefined

handle = (shard, payload) ->
    payload = JSON.stringify id: shard.options.id, payload: payload
    await ws.send payload if ws and ws.readyState is WebSocket.OPEN

init = (gateway) ->
    socket = new ShardManager {
        config: {
            token: process.env.GW_AUTH
            intents: GatewayIntents.Guilds | GatewayIntents.GuildMessages | GatewayIntents.MessageContent
        }
        gateway: gateway
        handleDiscordPayload: handle
    }

    console.log "Open gateway"

    socket.spawns()

rest.get("/gateway/bot").then(init).catch(console.error)
