local dns = require('dns')
local certs = require('./certs')
local tlsWrap = require('coro-tls').wrap
local tcp = require('coro-tcp')

local srvs = {
  "_monitoringagent._tcp.dfw1.prod.monitoring.api.rackspacecloud.com",
  "_monitoringagent._tcp.lon3.prod.monitoring.api.rackspacecloud.com",
  "_monitoringagent._tcp.ord1.prod.monitoring.api.rackspacecloud.com",
}


local function connect(srv)
  local thread = coroutine.running()
  print("Looking up " .. srv)
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
  p("TLS handshake complete")

end

coroutine.wrap(function ()
  for i = 1, #srvs do
    connect(srvs[i])
  end
end)()

