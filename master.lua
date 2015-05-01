
require('weblit-websocket')
require('weblit-app')

  .bind({
    host = "0.0.0.0",
    port = 4433,
    tls = {
      key = module:load("./key.pem"),
      cert = module:load("./cert.pem"),
    }
  })

  .use(require('weblit-logger'))
  .use(require('weblit-auto-headers'))

  .websocket({
    path = "/v2/socket",
    protocol = "virgo/2.0",
  }, require('./protocol'))

  .start()

require('uv').run()
