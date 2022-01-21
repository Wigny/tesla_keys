defmodule TeslaCase.Middleware.Remapper do
  @moduledoc """
  Tesla Middleware for remapping the body keys of the request and response.
  This middlware will convert all the keys of the body by their respective relation defined in the
  options before sending the request and after receiving the response

  ## Examples
  ```
  defmodule MyClient do
    use Tesla
    plug TeslaCase.Middleware.Remapper, keys: %{
      # key expected by API => key you want to handle instead
      "pong" => "ping",
      "bar" => "foo",
      "bye" => "hey"
    }
  end
  ```
  ## Options
  - `:keys` - list of keys expected by the API and that you want to handle
  """

  @behaviour Tesla.Middleware

  import TeslaCase, only: :macros

  @impl true
  def call(env, next, opts) do
    keys = Keyword.get(opts, :keys, %{})

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

  defp converter(body, keys, :encode) when is_map(body) do
    Map.new(body, fn {k, v} ->
      {key, _} = Enum.find(keys, {k, nil}, fn {_, r} -> r == k end)

      {key, converter(v, keys, :encode)}
    end)
  end

  defp converter(body, keys, :decode) when is_map(body) do
    Map.new(body, fn {k, v} -> {keys[k] || k, converter(v, keys, :decode)} end)
  end

  defp converter(value, keys, action) when is_list(value) do
    Enum.map(value, &converter(&1, keys, action))
  end

  defp converter(value, _keys, _encode) do
    value
  end
end
