# DivoVernemq

A library implementing the Divo Stack behaviour, providing a pre-configured VerneMQ broker via docker-compose for integration testing Elixir apps. The broker runs as a single-node "cluster".

## Installation

The package can be installed by adding `divo_vernemq` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:divo_vernemq, "~> 0.1.0"}
  ]
end
```

## Use

In your Mix configuration file (i.e. config/integration.exs), include the following at minimum:

```elixir
config :myapp,
  divo: [
    divo: [DivoVernemq]
  ],
  divo_wait: [dwell: 1_000, max_tries: 30]
```

In your integration test, specify that you want to use Divo:
```elixir
use Divo, services: [:vernemq]
```

The resulting stack will create a single VerneMQ broker server exposing the standard port 1883 for MQTT, 8883 for MQTT over SSL, 8080 for MQTT over Websockets, and 8888 for the Prometheus metrics port (and status web UI).

## Configuration

You may omit the configuration arguments to DivoVernemq and still have a working stack. The unmodified configuration will create the broker and expose the default ports as listed in the above example.

The following options are available for configuration:

  * `allow_anonymous`: Allow unauthenticated connections to the cluster. Defaults to `:on`

  * `mqtt_port`: The port on which the MQTT listener will be exposed to the host. The default
                 port VerneMQ uses for MQTT is 1883. The only affects the port exposed to the host;
                 within the container the VerneMQ broker is listening on port 1883.

  * `ssl_mqtt_port`: The port on which the MQTT over SSL communication will be exposed to the host.
                     The default port VerneMQ uses for MQTT over SSL is 8883. This only affects the
                     port exposed to the host; within the container, the VerneMQ broker is listening
                     on port 8883.

  * `ws_mqtt_port`: The port on which the MQTT over Websocket communication will be exposed to the host.
                    The default port VerneMQ uses for MQTT over websockets is 8080. This only
                    affects the port exposed to the host; within the container the VerneMQ broker
                    is listening on port 8080.

  * `stats_port`: The port on which the statistics web service, including the status UI, is exposed
                  to the host. The default port VerneMQ uses for the stats interface is 8888. This
                  only affects the host port; within the container the VerneMQ broker is listening on
                  port 8888. Set your browser to `localhost:<stats_port>/status` to view the UI.

  * `log_level`: The log level at which the VerneMQ broker will output messages. Defaults to `:info`.

  * `users`: A map of usernames and passwords to create records for file-based authentication. These
            are transparently converted to environment variables that are injected into the container
            in the form of `DOCKER_VERNEMQ_USER_<username>='password'`. Defaults to an empty map.
  * `version`: The version of the VerneMQ image to run. Defaults to `latest`.

See [Divo Github](https://github.com/smartcitiesdata/divo) or [Divo Hex Documentation](https://hexdocs.pm/divo) for more instructions on using and configuring the Divo library.
See [VerneMQ source](https://vernemq/vernemq) for the full codebase behind VerneMQ.
