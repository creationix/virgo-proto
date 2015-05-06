local config = require('config')
local makeSocket = require('socket')
local msgpack = require('msgpack')
local uv = require('uv')


local intervals = {}
local programs = {}

local api = require('uv')
local read, write

local function run(name)
  local fn = programs[name]
  p("Running", name, fn)
  local result = {name, fn(api)}
  write({
    opcode = 2,
    payload = msgpack.encode(result)
  })
end

local timer = uv.new_timer()
local function tick()
  timer:stop()
  local smallest
  local now = uv.now()
  for name, pair in pairs(intervals) do
    local start, interval = unpack(pair)
    if start <= now then
      while start <= now do
        start = start + interval
      end
      pair[1] = start
      run(name)
    end

    if not smallest or start < smallest then
      smallest = start
    end
  end
  if not smallest then return end
  local delay = smallest - now
  timer:start(delay * 1000, 0, tick)
end


local function compile(code, name)
  local fn = assert(loadstring(code, name))
  return fn
end

coroutine.wrap(function ()
  for i = 1, #config.endpoints do
    read, write = makeSocket(config.endpoints[i], config.ca)
    for message in read do
      assert(message.opcode == 2)
      local task, used = msgpack.decode(message.payload)
      assert(used == #message.payload)
      local name, code, interval = unpack(task)
      programs[name] = compile(code, name)
      if interval then
        intervals[name] = {uv.now(), interval}
        tick()
      else
        run(name)
      end
    end
    write()
  end
end)()

require('uv').run()


