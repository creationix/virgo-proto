local httpCodec = require('http-codec')
local connect = require('coro-tcp').connect
local tlsWrap = require('coro-tls').wrap
local wrapper = require('coro-wrapper')
local readWrap, writeWrap = wrapper.reader, wrapper.writer
local websocketCodec = require('websocket-codec')
local urlParse = require('url').parse

return function (url, ca)
  local uri = urlParse(url)
  assert(uri.protocol == "wss", "Only wss:// protocol supported in endpoint urls")
  print("Connecting to " .. url)

  -- Create a TCP connection
  local rawRead, rawWrite, socket = assert(connect(uri.hostname, uri.port or 443))

  -- Wrap it in transport layer security using custom server certificate
  rawRead, rawWrite = tlsWrap(rawRead, rawWrite, {
    ca = ca
  })

  -- Apply the http-codec so we can talk in terms of http events.
  local read, updateDecoder = readWrap(rawRead, httpCodec.decoder())
  local write, updateEncoder = writeWrap(rawWrite, httpCodec.encoder())

  -- Perform the websocket handshake
  local success, err = websocketCodec.handshake({
    host = uri.host,
    path = uri.path,
    {"User-Agent", "Virgo-Agent v2.0 unbound"},
    protocol = "virgo/2.0",
  }, function (req)
    write(req)
    local res = read()
    if not res then
      error("Server disconnected while requesting websocket upgrade")
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

