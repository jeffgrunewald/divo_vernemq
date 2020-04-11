defmodule DivoVernemqTest do
  use ExUnit.Case

  describe "produces a vernemq stack map" do
    test "with no specified arguments" do
      expected = %{
        vernemq: %{
          image: "jeffgrunewald/vernemq:latest",
          ports: ["1883:1883", "8883:8883", "8080:8080", "8888:8888"],
          environment: [
            "DOCKER_VERNEMQ_ALLOW_ANONYMOUS=on",
            "DOCKER_VERNEMQ_LOG__CONSOLE__LEVEL=info"
          ]
        }
      }

      actual = DivoVernemq.gen_stack([])

      assert actual == expected
    end

    test "produces a vernemq stack map with supplied environment variables" do
      expected = %{
        vernemq: %{
          image: "jeffgrunewald/vernemq:v2.1",
          ports: ["1111:1883", "2222:8883", "8080:8080", "8888:8888"],
          environment: [
            "DOCKER_VERNEMQ_ALLOW_ANONYMOUS=off",
            "DOCKER_VERNEMQ_LOG__CONSOLE__LEVEL=info",
            "DOCKER_VERNEMQ_USER_foo='bar'"
          ]
        }
      }

      actual =
        DivoVernemq.gen_stack(
          version: "v2.1",
          allow_anonymous: :off,
          users: %{foo: "bar"},
          mqtt_port: 1111,
          ssl_mqtt_port: 2222
        )

      assert actual == expected
    end
  end
end
