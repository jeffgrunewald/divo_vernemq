defmodule DivoVernemq do
  @moduledoc """
  Defines a single-node "cluster" vernemq broker
  as a map compatible with divo for building a
  docker-compose file.
  """

  @behaviour Divo.Stack

  @doc """
  Implements the Divo Stack behaviour to take a
  keyword list of defined variables specific to
  the DivoVernemq stack and returns a map describing
  the service definition of VerneMQ.

  ### Optional Configuration
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
  """
  @impl Divo.Stack
  @spec gen_stack([tuple()]) :: map()
  def gen_stack(envars) do
    version = Keyword.get(envars, :version, "latest")
    allow_anonymous = Keyword.get(envars, :allow_anonymous, :on) |> validate_allow_anon()
    mqtt_port = Keyword.get(envars, :mqtt_port, 1883)
    ssl_mqtt_port = Keyword.get(envars, :ssl_mqtt_port, 8883)
    ws_mqtt_port = Keyword.get(envars, :ws_mqtt_port, 8080)
    stats_port = Keyword.get(envars, :stats_port, 8888)
    log_level = Keyword.get(envars, :log_level, :info) |> validate_log_level()
    users = Keyword.get(envars, :users, %{})

    %{
      vernemq: %{
        image: "jeffgrunewald/vernemq:#{version}",
        ports: [
          "#{mqtt_port}:1883",
          "#{ssl_mqtt_port}:8883",
          "#{ws_mqtt_port}:8080",
          "#{stats_port}:8888"
        ],
        environment:
          [
            "DOCKER_VERNEMQ_ALLOW_ANONYMOUS=#{allow_anonymous}",
            "DOCKER_VERNEMQ_LOG__CONSOLE__LEVEL=#{log_level}"
          ] ++ inject_auth_users(users)
      }
    }
  end

  defp inject_auth_users(users) when users == %{}, do: []

  defp inject_auth_users(users) do
    Enum.map(users, fn {user, passwd} -> "DOCKER_VERNEMQ_USER_#{to_string(user)}='#{passwd}'" end)
  end

  defp validate_log_level(level)
       when level in [:debug, :info, :warning, :error, "debug", "info", "warning", "error"] do
    level
  end

  defp validate_log_level(_), do: "info"

  defp validate_allow_anon(allow) when allow in [:on, :off, "on", "off"], do: allow
  defp validate_allow_anon(_), do: "on"
end
