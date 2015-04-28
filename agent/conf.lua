local bundle = require('luvi').bundle
return {
  -- Used for remote poller
  -- If set this agent is assumed to be available for remote polling and
  -- can handle multiple tenants
  location = 'creationix-home',

  -- Load the ca used to authenticate the server endpoint.
  ca = bundle.readfile("ca.pem"),

  -- List of endpoints to connect to
  -- The agent will heartbeat and ntp with all endpoints, but will only
  -- send data up to the lowest latency connection.
  endpoints = {
    "wss://localhost:4433/v2/socket"
  }
}
