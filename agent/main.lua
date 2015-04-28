
coroutine.wrap(function ()
  local conf = require('./conf')
  local connect = require('connection')
  for i = 1, #conf.endpoints do
    p(connect(conf.endpoints[i], conf.ca))
  end
end)()

require('uv').run()


