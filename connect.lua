local dns = require('dns')
local certs = require('./certs')
local tlsWrap = require('coro-tls').wrap
local tcp = require('coro-tcp')
local jsonEncode = require('json').stringify
local jsonDecode = require('json').parse

local srvs = {
  "_monitoringagent._tcp.dfw1.prod.monitoring.api.rackspacecloud.com",
  -- "_monitoringagent._tcp.lon3.prod.monitoring.api.rackspacecloud.com",
  -- "_monitoringagent._tcp.ord1.prod.monitoring.api.rackspacecloud.com",
}

local find = string.find
local sub = string.sub

local function wrap(read, write)
  local buffer = ""
  return function ()
    local n = find(buffer, '\n', 1, true)
    while not n do
      local chunk = read()
      if not chunk then return nil, buffer end
      buffer = buffer .. chunk
      n = find(buffer, '\n', 1, true)
    end
    local json = sub(buffer, 1, n - 1)
    buffer = sub(buffer, n + 1)
    return jsonDecode(json)
  end,
  function (message)
    return write(jsonEncode(message) .. "\n")
  end
end

local token = "640c25207027fd8d26e8062b8528f99587409df408ad2b872e138b12c67f7f5d.921002"
local uuid = "287be3fa-c2f4-42c0-c2b7-3871eaab7954"
local agent_id = "proto"
local entity_id = "enMS1ubuw5"

local function connect(srv)
  local thread = coroutine.running()
  p(srv)
  local answers = assert(dns.resolveSrv(srv, thread))
  assert(#answers > 0)
  local host = answers[1].target
  local port = answers[1].port
  p(host, port)
  local read, write, socket = tcp.connect(host, port)
  p("TCP socket established", socket)
  read, write = tlsWrap(read, write, {
    protocol = "TLSv1",
    ca = certs.caCerts,
  })
  p("TLS handshake complete", read, write)
  read, write = wrap(read, write)
  write {
    v = '1',
    source = uuid,
    target = 'endpoint',
    method = 'handshake.hello',
    params = {
      agent_id = agent_id,
      features = {
        { name = 'upgrades', version = '1.0.0' },
        { name = 'confd', version = '1.0.0' }
      },
      agent_name = 'rackspace-monitoring-agent',
      process_version = '1.12.1',
      token = token,
      bundle_version = '1.12.1'
    },
  }

  local resp = read()
  p(resp)
  assert(resp.result)
  local heartbeat_interval = resp.result.heartbeat_interval
  p("heartbeat_interval", heartbeat_interval)
  write {
    v = '1',
    source = uuid,
    target = 'endpoint',
    method = 'config_file.post',
    id = '0',
    params = { dummy = 1 },
  }


  resp = read()
  p(resp)
end

coroutine.wrap(function ()
  for i = 1, #srvs do
    connect(srvs[i])
  end
end)()

