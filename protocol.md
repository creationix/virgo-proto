Protocol is based on `wss://` with msgpack serialization

Server authentication is accomplished with a custom server tls certificate
embedded in client.

Agent authentication is done with the `User-Agent` header.

The `X-Virgo-Client` header is set for each client the agent represents.

The value is the client's id along with a comma separated list of capabilities
such as:

 - internal - The agent is inside the machine (monitoring agent)
 - external - The agent is external to the machine (remote poller)
 - readonly - The client has restricted this agent to only reading information
 - collector

Sample headers for a polling agent that also watches itself from the inside.

```http
User-Agent: Virgo-Agent v2.0.2 zxcv876sasd8796v9ajh
X-Virgo-Client: 38457f7xfdsa internal,readonly
X-Virgo-Client: sdf678adf6ad external
X-Virgo-Client: vzpl2359vjzs external
Sec-WebSocket-Protocol: virgo/2.0
```

Upon successful connection, the server will upgrade to websocket and tell the
agent it's repeating tasks (checks).

A task will contain a client-id, task-id, interval, type and arguments for
that type. The agent will automatically scatter the items so that they don't
happen all at once.

    <- [client-id, task-id, interval, type, ...]
    <- [client-id, task-id, interval, type, ...]
    <- [client-id, task-id, interval, type, ...]

To send a response, send a list with client-id, task-id, timestamp and delay
delts since task/request and message as a binary blob and it will be routed to
dest by all nodes in the network.

    -> [client-id, task-id, timestamp, delta, message]

When the server wishes to update the list of tasks, it will send down the
diff.  Tasks to delete will simply contain the client-id and task-id and
nothing else.

When a client wishes to disconnect gracefully, it will send a single `false`

    -> false

Likewise, when the master wishes to kill an agent, it will send a single `false`

    <- false

If the master wishes to make a one-shot request, it will send a task with an
interval of 0.

    <- [client-id, task-id, 0, type, ...]

The agent will respond as usual:

    -> [client-id, task-id, timestamp, delta, message]

In the task, the "type" will be a lit package name.  If the agent doesn't have
this code locally, it will download it via the lit protocol through the
master.  The packages will be cached locally in a litdb and only updates will
be downloaded.

The tasks themselves will be run in workers (sub processes or threads) and
have hot-reload ability if a task is updated.
