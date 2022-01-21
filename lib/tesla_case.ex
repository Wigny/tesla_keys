defmodule TeslaCase.Middleware do
  @moduledoc """
  Tesla middleware for converting the body keys of the request and response.
  This middleware will convert all keys from the body of the request using the appropriate
  function before performing it and will convert all keys from the body of the response to
  snake case.

  ## Examples
  ```
  defmodule MyClient do
    use Tesla
    plug TeslaCase.Middleware # use defaults
    # or
    plug TeslaCase.Middleware, encode: &Recase.to_camel/1, serializer: &Recase.Enumerable.atomize_keys/2
    # or
    plug TeslaCase.Middleware, encode: &String.upcase/1, serializer: &serializer/2

    defp serializer(data, encode) do
      Map.new(data, fn {key, value} -> {then(key, encode), value} end)
    end
  end
  ```
  ## Options
  - `:serializer` - serializer function with arity 2, receives the data as the first parameter and the `:encode` as the second parameter, (defaults to `&Recase.Enumerable.stringify_keys/2`)
  - `:encode` - encoding function, e.g `&Recase.to_camel/1`, `&Recase.to_pascal/1` (defaults to `&Recase.to_camel/1`)
  - `:decode` - decoding function (defaults to `&Recase.to_snake/1`)
  """

  @behaviour Tesla.Middleware

  defguardp is_enum(data) when is_map(data) or is_list(data)

  @impl true
  def call(env, next, opts) do
    serializer = Keyword.get(opts, :serializer, &Recase.Enumerable.stringify_keys/2)
    encode = Keyword.get(opts, :encode, &Recase.to_camel/1)
    decode = Keyword.get(opts, :decode, &Recase.to_snake/1)

    env
    |> request(serializer, encode)
    |> Tesla.run(next)
    |> response(serializer, decode)
  end

  defp request(%{body: body} = env, serializer, encode) when is_enum(body) do
    %{env | body: converter(body, serializer, encode)}
  end

  defp request(env, _serializer, _encode) do
    env
  end

  defp response({:ok, env}, serializer, decode) when is_enum(env.body) do
    env = %{env | body: converter(env.body, serializer, decode)}

    {:ok, env}
  end

  defp response(env, _serializer, _decode) do
    env
  end

  defp converter(data, serializer, converter) do
    apply(serializer, [data, converter])
  end
end
