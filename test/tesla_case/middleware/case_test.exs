defmodule TeslaCase.Middleware.CaseTest do
  use ExUnit.Case
  doctest TeslaCase.Middleware.Case

  setup context do
    middlewares = [{TeslaCase.Middleware.Case, Map.get(context, :opts, [])}]

    adapter = fn env ->
      case env.url do
        "/request" ->
          send(self(), env)
          {:ok, %Tesla.Env{}}

        "/response" ->
          {:ok, %Tesla.Env{body: %{"fooBar" => "ok"}}}
      end
    end

    client = Tesla.client(middlewares, &then(&1, adapter))

    %{client: client}
  end

  describe "converts request body" do
    test "to camel case", %{client: client} do
      Tesla.get(client, "/request", body: %{foo_bar: "ok"})

      assert_received %{body: %{"fooBar" => "ok"}}
    end

    @tag opts: [encode: &Recase.to_pascal/1]
    test "to a custom case", %{client: client} do
      Tesla.get(client, "/request", body: %{foo_bar: "ok"})

      assert_received %{body: %{"FooBar" => "ok"}}
    end
  end

  describe "converts response body" do
    test "to snake case", %{client: client} do
      assert {:ok, %{body: %{"foo_bar" => "ok"}}} = Tesla.get(client, "/response")
    end

    @tag opts: [serializer: &Recase.Enumerable.atomize_keys/2]
    test "to snake case atomizing", %{client: client} do
      assert {:ok, %{body: %{foo_bar: "ok"}}} = Tesla.get(client, "/response")
    end
  end
end
