defmodule TeslaKeys.Middleware.Remapper do
  @moduledoc """
  Tesla middleware for remapping request and response body keys.

  This middleware will remap the body keys by their respective relations defined in the options
  before sending the request and after receiving the response. All unmapped keys will be kept as
  is when doing the convertion.

  ## Examples
  ```
  defmodule MyClient do
    use Tesla
    plug TeslaKeys.Middleware.Remapper, keys: %{
      # key expected by API => key you want to handle instead
      "pong" => "ping",
      "bar" => "foo",
      "bye" => "hey"
    }
    # or if you are working with atom keys map
    plug TeslaKeys.Middleware.Remapper, keys: [
      # "key expected by API": :"key you want to handle instead"
      pong: :ping,
      bar: :foo,
      bye: :hey
    ]
  end
  ```
  ## Options
  - `:keys` - relation of keys expected by the API and that you want to handle
  """

  @behaviour Tesla.Middleware

  import TeslaKeys, only: :macros

  @impl true
  def call(env, next, opts) do
    keys_opts = opts |> Keyword.get(:keys, []) |> Map.new()
    keys_environment = :tesla |> Application.get_env(:remapper_keys, []) |> Map.new()
    keys = Map.merge(keys_opts, keys_environment)

    env
    |> request(keys)
    |> Tesla.run(next)
    |> response(keys)
  end

  defp request(%{body: body} = env, keys) when is_enum(body) do
    %{env | body: converter(body, keys, :encode)}
  end

  defp request(env, _keys) do
    env
  end

  defp response({:ok, env}, keys) when is_enum(env.body) do
    env = %{env | body: converter(env.body, keys, :decode)}

    {:ok, env}
  end

  defp response(env, _keys) do
    env
  end

  defp converter(value, keys, action) when is_map(value) do
    Map.new(value, &converter(&1, keys, action))
  end

  defp converter(value, keys, action) when is_list(value) do
    Enum.map(value, &converter(&1, keys, action))
  end

  defp converter({key, value}, keys, action) do
    {fetch(key, keys, action), converter(value, keys, action)}
  end

  defp converter(value, _keys, _action) do
    value
  end

  defp fetch(key, keys, :encode) do
    keys |> Enum.find({key, nil}, &match?({_, ^key}, &1)) |> elem(0)
  end

  defp fetch(key, keys, :decode) do
    Map.get(keys, key, key)
  end
end
