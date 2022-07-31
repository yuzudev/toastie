import { DefaultRestAdapter } from "@biscuitland/rest"
import Fastify from "fastify"
import "dotenv/config"

manager = new DefaultRestAdapter {
    url: "http://localhost:#{process.env.REST_PORT}"
    token: process.env.GW_AUTH
    version: 10
}

console.log "Iniciando rest manager en puerto #{process.env.REST_PORT}"

app = Fastify {}

app.all "*", (req, reply) ->
    response = switch req.method
        when "GET" then await rest.get req.url, req.body
        when "POST" then await rest.post req.url, req.body
        when "PUT" then await rest.put req.url, req.body
        when "PATCH" then await rest.patch req.url, req.body
        when "DELETE" then await rest.delete req.url, req.body

    if response then reply.status(200).send status: 200, data: response
    else reply.status(204).send status: 204, data: null

app.listen port: process.env.REST_PORT
