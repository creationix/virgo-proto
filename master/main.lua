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
    p("websocket", req)
    for message in read do
      write(message)
    end
    write()
  end)

  .start()

require('uv').run()

