defmodule TeslaKeys.Middleware.RemapperTest do
  use ExUnit.Case
  alias TeslaKeys.Middleware.Remapper
  doctest Remapper

  setup do
    middlewares = [{Remapper, keys: %{"bar_foo" => "foo_bar", "pong" => "ping"}}]

    client =
      Tesla.client(middlewares, fn %{url: "/path"} = env ->
        send(self(), env)
        {:ok, %Tesla.Env{body: %{"bar_foo" => "ok", "test" => true}}}
      end)

    %{client: client}
  end

  test "replaces request body keys", %{client: client} do
    Tesla.get(client, "/path", body: %{"foo_bar" => [%{"test" => true, "ping" => "ok"}]})

    assert_received %{body: %{"bar_foo" => [%{"test" => true, "pong" => "ok"}]}}
  end

  test "replaces response body keys", %{client: client} do
    assert {:ok, %{body: %{"foo_bar" => "ok", "test" => true}}} = Tesla.get(client, "/path")
  end

  test "reads configuration keys from application environment", %{client: client} do
    Application.put_env(:tesla, :remapper_keys, [{"test", "dev"}])
    on_exit(fn -> Application.delete_env(:tesla, :remapper_keys) end)

    assert {:ok, %{body: %{"dev" => true}}} = Tesla.get(client, "/path")
  end
end
