local modules = {
  tcp = require('./tcp')
}

local function runCheck(attributes, config, callback)
  local fn = assert(modules[attributes.module], "Missing module")

  -- TODO: add timeout

  local handles = {}
  local function register(handle)
    handles[#handles + 1] = handle
  end

  coroutine.wrap(function ()
    local success, result = pcall(fn, attributes, config, register)
    for i = 1, #handles do
      if not handles[i]:is_closing() then handles[i]:close() end
    end
    if not success then
      callback(nil, result)
    else
      callback(result)
    end
  end)()
end

runCheck({
  target = "127.0.0.1",
  module = "tcp",
  timeout = 1000,
}, {
  port = 22,
  banner_match = "SSH",
  -- body_match = "stuff"
}, p)
