import { DefaultWsAdapter } from "@biscuitland/ws"
import { DefaultRestAdapter } from "@biscuitland/rest"
import { GATEWAY_BOT, GatewayIntents } from "@biscuitland/api-types"
import "dotenv/config"

intents = GatewayIntents.Guilds | GatewayIntents.GuildMessages | GatewayIntents.MessageContent

restManager = new DefaultRestAdapter {
    url: "http://localhost:#{process.env.REST_PORT}"
    token: process.env.GW_AUTH
}

config = await restManager.get "/gateway/bot"
    .then (res) ->
        url: res.url,
        shards: res.shards,
        sessionStartLimit:
            total: res.session_start_limit.total,
            remaining: res.session_start_limit.remaining,
            resetAfter: res.session_start_limit.reset_after,
            maxConcurrency: res.session_start_limit.max_concurrency,

wsManager = new DefaultWsAdapter {
    gatewayConfig:
        token: process.env.GW_AUTH
        intents: intents

    handleDiscordPayload: (shard, data) ->
        if data.t
            await fetch "http://localhost:#{process.env.GW_PORT}", {
                method: "POST"
                body: JSON.stringify shardId: shard.id, data: data
            }
            .then (res) -> do res.text
            .catch (err) -> null
}

wsManager.options.gatewayBot = config
wsManager.options.lastShardId = wsManager.options.gatewayBot.shards - 1
wsManager.options.totalShards = wsManager.options.gatewayBot.shards
wsManager.agent.options.totalShards = wsManager.options.gatewayBot.shards

do wsManager.shards
