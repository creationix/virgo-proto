local uv = require('uv')
local bundle = require('luvi').bundle
local httpCodec = require('http-codec')
local connect = require('coro-tcp').connect
local tlsWrap = require('coro-tls').wrap
local wrapper = require('coro-wrapper')
local readWrap, writeWrap = wrapper.reader, wrapper.writer
local websocketCodec = require('websocket-codec')
local urlParse = require('url').parse

local function join(host, port, path)
  -- Make a TCP connection
  p(string.format("Connecting to wss://%s:%d%s...", host, port, path))
  local rawRead, rawWrite, socket = assert(connect(host, port))
  -- And wrap stream in tls
  rawRead, rawWrite = tlsWrap(rawRead, rawWrite, {
    ca = bundle.readfile("cert.pem")
  })

  local read, updateDecoder = readWrap(rawRead, httpCodec.decoder())
  local write, updateEncoder = writeWrap(rawWrite, httpCodec.encoder())

  -- Perform the websocket handshake
  local success, err = websocketCodec.handshake({
    host = host,
    path = path,
    {"User-Agent", "Virgo-Agent v2.0 zxcv876sasd8796v9ajh"},
    protocol = "virgo/2.0",
  }, function (req)
    write(req)
    local res = read()
    if not res then error("Missing server response") end
    if res.code == 400 then
      p { req = req, res = res }
      local reason = read() or res.reason
      error("Invalid request: " .. reason)
    end
    return res
  end)

  if not success then
    error(read() or err)
  end

  -- Upgrade the protocol to websocket
  updateDecoder(websocketCodec.decode)
  updateEncoder(websocketCodec.encode)

  return read, write, socket
end

coroutine.wrap(function ()
  local config = require('./conf')

  p(config)
  local endpoints = config.endpoints
  for i = 1, #endpoints do
    local uri = urlParse(endpoints[i])
    assert(uri.protocol == "wss", "endpoints must be wss protocol")
    local read, write, socket = join(uri.hostname, tonumber(uri.port or 443), uri.pathname)
    p("connected", socket)

    local client = {
      index = 1, -- Used
      id = "1234987ghjxcmnbwquiyh2",
      capabilities = ""
    }
    p("asking for work for client", client)
    for data in read do
      p(data)
    end

  end
end)()

uv.run()

--[[
Client -> Server Messages:

Server -> Client Messages:
]]
