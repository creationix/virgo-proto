--[[
api currently contains:

 - getuid()
 - getpid()
 - getgid()
 - get_process_title()
 - get_total_memory()
 - resident_set_memory()
 - getaddrinfo(options)
 - getnameinfo(options)
 - getrusage()
 - cpu_info()
 - cwd()
 - interface_addresses()
 - loadavg()
 - exepath()
 - uptime()
 - hrtime()
 - now()

]]

local msgpack = require('msgpack')
local tasks = {
  { "stat-init",
    string.dump(function (api)
      return {
        uid = api.getuid(),
        gid = api.getgid(),
        pid = api.getpid(),
        title = api.get_process_title(),
        mem = api.get_total_memory(),
        cpu = api.cpu_info(),
        inet = api.interface_addresses(),
        cwd = api.cwd(),
        exe = api.exepath(),
      }
    end, true),
  },
  { "stat-update",
    string.dump(function (api)
      return {
        rss = api.resident_set_memory(),
        rusage = api.getrusage(),
        loadavg = {api.loadavg()},
        uptime = api.uptime()
      }
    end, true),
    5
  }
}


-- This is called every time a new websocket client connects.
return function (req, read, write)
  p(req)
  for i = 1, #tasks do
    local task = tasks[i]
    write({
      opcode = 2,
      payload = msgpack.encode(task)
    })
  end
  for message in read do
    p(message)
  end
  write()
end
