local uv = require('uv')

local modules = {
  tcp = require('./tcp')
}

local function runCheck(attributes, config, callback)
  local fn = assert(modules[attributes.module], "Missing module")

  local done
  local handles = {}
  local result = {}

  -- Register a uv_handle to be cleaned up when done.
  local function register(handle)
    if done then
      return handle:close()
    end
    handles[#handles + 1] = handle
  end

  -- Set part of the result data.
  local function set(key, value)
    result[key] = value
  end

  -- Called when done with optional error reason
  local function finish(err)
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
    return finish("ETIMEOUT: Check did not finish within " .. attributes.timeout .. "ms")
  end)

  coroutine.wrap(function ()
    local success, err = pcall(fn, attributes, config, register, set)
    if not success then
      return finish(err)
    end
    return finish()
  end)()
end

runCheck({
  id = 42,
  target = "creationix.com",
  family = "inet4",
  -- family = "inet6", -- Need ISP with ipv6 to test
  module = "tcp",
  timeout = 200,
}, {
  port = 80,
  send_body = "GET / HTTP/1.0\r\n\r\n",
  body_match = "^HTTP/1\\.[10] 200 OK"
}, p)

-- runCheck({
--   id = 42,
--   target = "127.0.0.1",
--   family = "inet4",
--   module = "tcp",
--   timeout = 2000,
-- }, {
--   port = 22,
--   banner_match = "SSH",
-- }, p)
