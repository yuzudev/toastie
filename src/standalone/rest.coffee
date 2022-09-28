import { DefaultRestAdapter } from "@biscuitland/rest"
import Fastify from "fastify"
import "dotenv/config"

manager = new DefaultRestAdapter {
    token: process.env.GW_AUTH
    version: 10
}

console.log "Open rest #{process.env.REST_PORT}"

app = Fastify {}

app.all "*", (req, reply) ->
    url = req.url.replace "v10", ""
    response = switch req.method
        when "GET" then await rest.get url, req.body
        when "POST" then await rest.post url, req.body
        when "PUT" then await rest.put url, req.body
        when "PATCH" then await rest.patch url, req.body
        when "DELETE" then await rest.delete url, req.body

    if response then reply.status(200).send status: 200, data: response
    else reply.status(204).send status: 204, data: null

app.listen port: process.env.REST_PORT
