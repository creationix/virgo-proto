local config = require('config')
local makeSocket = require('socket')
local msgpack = require('msgpack')
local uv = require('uv')


local intervals = {}
local programs = {}

local api = require('uv')

local nextCheck
local function recheck()
  for i = 1, #intervals do
    local name, start, interval = unpack(intervals[i])
    if not nextCheck or start < nextCheck then
      nextCheck = start
    end


end

local function run(name, bytecode, interval)
  local fn = assert(loadstring(bytecode, name))
  print("Running task: " .. name)
  if interval then
    programs[name] = fn
    intervals[#intervals + 1] = {
      name, uv.now() + interval, interval,
    }
  end
  local result = fn(api)
  p("result", result)
end


coroutine.wrap(function ()
  for i = 1, #config.endpoints do
    local read, write = makeSocket(config.endpoints[i], config.ca)
    for message in read do
      assert(message.opcode == 2)
      local task = msgpack.decode(message.payload)
      run(unpack(task))
      task.task = loadstring(task.task, task.name)
      p(task)
    end
    write()
  end
end)()

require('uv').run()


