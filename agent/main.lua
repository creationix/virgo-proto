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
  local rawRead, rawWrite, socket = assert(connect(host, port))
  -- And wrap stream in tls
  p("connected", socket)
  rawRead, rawWrite = tlsWrap(rawRead, rawWrite, {
    ca = bundle.readfile("cert.pem")
  })
  p("tls session", socket)

  local read, updateDecoder = readWrap(rawRead, httpCodec.decoder())
  local write, updateEncoder = writeWrap(rawWrite, httpCodec.encoder())

  -- Perform the websocket handshake
  assert(websocketCodec.handshake({
    host = host,
    path = path,
    {"User-Agent", "Virgo-Agent v2.0.2 zxcv876sasd8796v9ajh"},
    {"X-Virgo-Client", "38457f7xfdsa internal,readonly"},
    {"X-Virgo-Client", "sdf678adf6ad external"},
    {"X-Virgo-Client", "vzpl2359vjzs external"},
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
  end))

  -- Upgrade the protocol to websocket
  updateDecoder(websocketCodec.decode)
  updateEncoder(websocketCodec.encode)

  return read, write, socket
end

coroutine.wrap(function ()
  p(join("localhost", 4433, "/"))
end)()

uv.run()
