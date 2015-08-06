local uv = require('uv')

local modules = {
  tcp = require('./tcp')
}

local function runCheck(attributes, config, callback)
  local fn = assert(modules[attributes.module], "Missing module")

  local done
  local handles = {}
  local function register(handle)
    if done then
      return handle:close()
    end
    handles[#handles + 1] = handle
  end

  local function cleanup(err, result)
    if done then return end
    done = true
    for i = 1, #handles do
      if not handles[i]:is_closing() then handles[i]:close() end
    end
    return callback(err, result)
  end

  local timer = uv.new_timer()
  register(timer)
  timer:start(attributes.timeout, 0, function ()
    return cleanup("ETIMEOUT: Check did not finish within " .. attributes.timeout .. "ms")
  end)

  coroutine.wrap(function ()
    local success, result = pcall(fn, attributes, config, register)
    if success then
      return cleanup(nil, result)
    else
      return cleanup(result)
    end
  end)()
end

runCheck({
  target = "127.0.0.1",
  module = "tcp",
  timeout = 20,
}, {
  port = 22,
  banner_match = "SSH",
  -- body_match = "stuff"
}, p)
