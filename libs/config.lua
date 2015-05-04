return {
  -- Path to external config (Where the location property would normally go)
  external = "/etc/virgo-agent/config.lua",

  -- Hint to tell AEP what data-center we're in. This implies we are multi-
  -- tenant and can perform remote-poll tasks.
  location = 'creationix-home',

  -- List of endpoints to connect to.
  -- The agent will heartbeat and ntp with all endpoints, but will only
  -- send data up to the lowest latency connection.
  endpoints = {
    "wss://localhost:4433/v2/socket"
  },

  -- A common certificate is used to authenticate all endpoints.
  -- In this case it's the certificate itself since it's self-signed.
  ca = module:load("../cert.pem")

}
