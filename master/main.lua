local bundle = require('luvi').bundle

require('weblit-websocket')
require('weblit-app')

  .bind({
    host = "0.0.0.0",
    port = 4433,
    tls = {
      key = bundle.readfile("key.pem"),
      cert = bundle.readfile("cert.pem"),
    }
  })

  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))

  .websocket({
    protocol = "virgo/2.0",
  }, function (req, read, write, socket)
    local agent = {}
    local clients = {}
    agent.clients = clients
    local headers = req.headers
    for i = 1, #headers do
      local key, value = unpack(headers[i])
      key = key:lower()
      if key == "user-agent" then
        local version, id = value:match("Virgo%-Agent v(%d[%d.]*) ([^ ]+)")
        if version then
          agent.id = id
          agent.version = version
        end
      elseif key == "x-virgo-client" then
        local id, props = value:match("([^ ]+) (.*)")
        local client = {}
        for prop in props:gmatch("[^ ,]+") do
          client[prop] = true
        end
        clients[id] = client
      end
    end
    p("websocket", agent)
    if agent.version ~= "2.0" then
      error("Virgo-Agent 2.0 required in User-Agent")
    end

    write()
    for message in read do
      write(message)
    end
    write()
  end)

  .start()

require('uv').run()

