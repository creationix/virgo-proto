-- This is called every time a new websocket client connects.
return function (req, read, write)
  local agent = {}
  local userAgent = req.headers["user-agent"]
  if not userAgent then
    error("User-Agent required")
  end
  local version = userAgent:match("Virgo%-Agent v(%d[%d.]*)")
  if version ~= "2.0" then
    error("Virgo-Agent 2.0 required in User-Agent")
  end
  agent.version = version
  p("websocket", agent)

  write()
  for message in read do
    write(message)
  end
  write()
end
