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
  ca = [[-----BEGIN CERTIFICATE-----
MIIEXjCCA0agAwIBAgIJAMHNKgrl2cLiMA0GCSqGSIb3DQEBBQUAMHwxCzAJBgNV
BAYTAlVTMQ4wDAYDVQQIEwVUZXhhczERMA8GA1UEBxMIUmVkIExpY2sxEzARBgNV
BAoTCkNyZWF0aW9uaXgxEjAQBgNVBAMTCWxvY2FsaG9zdDEhMB8GCSqGSIb3DQEJ
ARYSdGltQGNyZWF0aW9uaXguY29tMB4XDTE1MDQxNjIyMTI1NVoXDTE1MDUxNjIy
MTI1NVowfDELMAkGA1UEBhMCVVMxDjAMBgNVBAgTBVRleGFzMREwDwYDVQQHEwhS
ZWQgTGljazETMBEGA1UEChMKQ3JlYXRpb25peDESMBAGA1UEAxMJbG9jYWxob3N0
MSEwHwYJKoZIhvcNAQkBFhJ0aW1AY3JlYXRpb25peC5jb20wggEiMA0GCSqGSIb3
DQEBAQUAA4IBDwAwggEKAoIBAQDo7v90ft+yP3K8q+6NEal7SD/lFF6LbvjfB5Al
/rGEoXr5YaCpBS9jTtfqD8LZm1zLW7tIq+ScwOqLDJ+xKbAIYgwbYdCOoci5wg7B
jKgfSuiSR0zYd1AGEPC33+gezRk3y5/9BKKhmjx0q/+nbO1HZVaGMhP3I70FEI6e
PlSsBiB+FoRAupRvXpXR1ENhyKnKH4khter++YGsBnPDEQPHNTKHixs1KtHlN0U6
gspWexPkmFtulye5grvl+2MIunmzcLRyjA2WB9F3ShCcDsRxb4MG+9dpuBWjfRs0
Zx+NN0HsnQpwZGM15lGcRL/vbBkdICgA0EJZ9oArnt0fg4f7AgMBAAGjgeIwgd8w
HQYDVR0OBBYEFNldziEmlauUoPNEriWhZawr4VzvMIGvBgNVHSMEgacwgaSAFNld
ziEmlauUoPNEriWhZawr4VzvoYGApH4wfDELMAkGA1UEBhMCVVMxDjAMBgNVBAgT
BVRleGFzMREwDwYDVQQHEwhSZWQgTGljazETMBEGA1UEChMKQ3JlYXRpb25peDES
MBAGA1UEAxMJbG9jYWxob3N0MSEwHwYJKoZIhvcNAQkBFhJ0aW1AY3JlYXRpb25p
eC5jb22CCQDBzSoK5dnC4jAMBgNVHRMEBTADAQH/MA0GCSqGSIb3DQEBBQUAA4IB
AQDCyUvduVfpLwFij70aEX7PEQ+Jgcoaw7qVNXJb9en+1kZxwaiSU6WOAO16C39p
StlGLn3kWMe8GX4y+mgde7KNTZU/waqxhhTnAphTtcIf6wlbDa0WLBhzWxiE4q8d
cvWl3u71l0ThKqhndYND6VCrwD0sBp/5Uy42BM0mAMBIyNjjHoxmXi5ccNfgPLHl
SHob/Zp3tTMqulLDpY66HlkQrCr4F6HVQdTnnHQKZdx9EYuDPYe8UsCnAnv33rmy
x6OKbx5GSCW5U9SP2MNz+L6YZtTL44RLAKNa4MTrvKYYpqpwK+3IC0E5zkQPhRgx
S+kVZvkyvR8G28074bWLlnmY
-----END CERTIFICATE-----
]]

}