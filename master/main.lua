local uv = require('uv')
local bundle = require('luvi').bundle
local httpCodec = require('http-codec')
local createServer = require('coro-tcp').createServer
local tlsWrap = require('coro-tls').wrap
local wrapper = require('coro-wrapper')
local readWrap, writeWrap = wrapper.reader, wrapper.writer
local websocketCodec = require('websocket-codec')

local opts = {
  server = true,
  key = bundle.readfile("key.pem"),
  cert = bundle.readfile("cert.pem"),
}

createServer("0.0.0.0", 4433, function (rawRead, rawWrite, socket)
  p("TCP client", socket)
  -- wrap stream in tls
  rawRead, rawWrite = tlsWrap(rawRead, rawWrite, opts)
  p("tls client", socket)

  local read, updateDecoder = readWrap(rawRead, httpCodec.decoder())
  local write, updateEncoder = writeWrap(rawWrite, httpCodec.encoder())

  p(read())
  write({code=404})
  write("")
  write()
end)

print("Server listening as wss://localhost:4433/")
uv.run()
