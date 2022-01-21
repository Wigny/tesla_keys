defmodule TeslaCase.Middleware.RemapperTest do
  use ExUnit.Case
  alias TeslaCase.Middleware.Remapper
  doctest Remapper

  setup context do
    middlewares = [{Remapper, keys: %{"bar_foo" => "foo_bar", "pong" => "ping"}}]

    client =
      Tesla.client(middlewares, fn env ->
        case env.url do
          "/request" ->
            send(self(), env)
            {:ok, %Tesla.Env{}}

          "/response" ->
            {:ok, %Tesla.Env{body: %{"bar_foo" => "ok", "test" => 1}}}
        end
      end)

    %{client: client}
  end

  test "replaces request body keys", %{client: client} do
    Tesla.get(client, "/request", body: %{"foo_bar" => [%{"test" => 1, "ping" => true}]})

    assert_received %{body: %{"bar_foo" => [%{"test" => 1, "pong" => true}]}}
  end

  test "replaces response body keys", %{client: client} do
    assert {:ok, %{body: %{"foo_bar" => "ok", "test" => 1}}} = Tesla.get(client, "/response")
  end
end
