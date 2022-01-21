defmodule TeslaKeys.Middleware.Case do
  @moduledoc """
  Tesla middleware for case conversion of request and response body keys.

  This middleware will do the case conversion of body keys using the functions defined in
  the options before sending the request and after receiving the response.

  ## Examples
  ```
  defmodule MyClient do
    use Tesla
    plug TeslaKeys.Middleware.Case # use defaults
    # or
    plug TeslaKeys.Middleware.Case, encoder: &Recase.to_camel/1, serializer: &Recase.Enumerable.atomize_keys/2
    # or
    plug TeslaKeys.Middleware.Case, encoder: &String.upcase/1, serializer: &serializer/2

    defp serializer(data, fun) when is_map(data), do: Map.new(data, fn {key, value} -> {then(key, fun), value} end)
    defp serializer(data, fun) when is_list(data), do: Enum.map(data, &serializer(&1, fun))
    defp serializer(data, _fun), do: data
  end
  ```
  ## Options
  - `:serializer` - serializer function with arity 2, receives the body data as the first parameter and the `:encoder` or `:decoder` option as the second parameter, (defaults to `&Recase.Enumerable.stringify_keys/2`)
  - `:encoder` - encoding function, e.g `&Recase.to_camel/1`, `&Recase.to_pascal/1` (defaults to `&Recase.to_camel/1`)
  - `:decoder` - decoding function (defaults to `&Recase.to_snake/1`)
  """

  @behaviour Tesla.Middleware

  import TeslaKeys, only: :macros

  @impl true
  def call(env, next, opts) do
    serializer = Keyword.get(opts, :serializer, &Recase.Enumerable.stringify_keys/2)
    encoder = Keyword.get(opts, :encoder, &Recase.to_camel/1)
    decoder = Keyword.get(opts, :decoder, &Recase.to_snake/1)

    env
    |> request(serializer, encoder)
    |> Tesla.run(next)
    |> response(serializer, decoder)
  end

  defp request(%{body: body} = env, serializer, encoder) when is_enum(body) do
    %{env | body: converter(body, serializer, encoder)}
  end

  defp request(env, _serializer, _encoder) do
    env
  end

  defp response({:ok, env}, serializer, decoder) when is_enum(env.body) do
    env = %{env | body: converter(env.body, serializer, decoder)}

    {:ok, env}
  end

  defp response(env, _serializer, _decoder) do
    env
  end

  defp converter(data, serializer, converter), do: apply(serializer, [data, converter])
end
