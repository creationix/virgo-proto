local config = require('config')
local makeSocket = require('socket')

coroutine.wrap(function ()
  for i = 1, #config.endpoints do
    p(makeSocket(config.endpoints[i], config.ca))
  end
end)()

require('uv').run()


