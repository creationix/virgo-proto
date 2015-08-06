local runCheck = require('./index')

-- runCheck({
--   id = 42,
--   target = "creationix.com",
--   family = "inet4",
--   -- family = "inet6", -- Need ISP with ipv6 to test
--   module = "tcp",
--   timeout = 200,
-- }, {
--   port = 80,
--   send_body = "GET / HTTP/1.0\r\n\r\n",
--   body_match = "^HTTP/1\\.[10] 200 OK"
-- }, p)

runCheck({
  id = 42,
  target = "creationix.com",
  family = "inet4",
  -- family = "inet6", -- Need ISP with ipv6 to test
  module = "tcp",
  timeout = 500,
}, {
  port = 443,
  use_ssl = true,
  send_body = "GET / HTTP/1.0\r\n" ..
              "Host: creationix.com\r\n\r\n",
  body_match = "^HTTP/1\\.[10] 200 OK"
}, p)

-- runCheck({
--   id = 43,
--   target = "127.0.0.1",
--   family = "inet4",
--   module = "tcp",
--   timeout = 2000,
-- }, {
--   port = 22,
--   banner_match = "SSH",
-- }, p)

-- runCheck({
--   id = 44,
--   target = "creationix.com",
--   family = "inet4",
--   -- family = "inet6", -- Need ISP with ipv6 to test
--   module = "http",
--   timeout = 200,
-- }, {
--   method = "GET",
--   url = "http://howtonode.org/",
--   -- headers = {
--   --   {"User-Agent", "Remote Agent Check"}
--   -- },
--   -- auth = {
--   --   method = "Basic",
--   --   user = "foo",
--   --   password = "bar"
--   -- },
--   code = 200,
--   -- redirects = 0,
--   body = "How To Node",
--   body_match_node_type = "Wheat v2 running on ([^ ]+)",
--   body_match_node_version = "Wheat v2 running on [^ ]+ v([0-9.]+)",
--   -- extract =
-- })
