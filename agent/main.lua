local uv = require('uv')
local bundle = require('luvi').bundle
local httpCodec = require('http-codec')
local connect = require('coro-tcp').connect
local tlsWrap = require('coro-tls').wrap
local wrapper = require('coro-wrapper')
local readWrap, writeWrap = wrapper.reader, wrapper.writer
local websocketCodec = require('websocket-codec')

local function join(host, port, path)
  -- Make a TCP connection
  p(string.format("Connecting to wss://%s:%d/%s...", host, port, path))
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
  local read, write, socket = join("localhost", 4433, "/v2/socket")
  p("connected", socket)
  for data in read do
    p(data)
  end
end)()

uv.run()
