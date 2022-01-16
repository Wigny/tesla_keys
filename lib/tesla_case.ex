defmodule TeslaCase.Middleware do
  @moduledoc """
  Documentation for `TeslaCase`.
  """

  alias Recase.Enumerable

  @behaviour Tesla.Middleware

  @impl true
  def call(env, next, opts) do
    serializer = Keyword.get(opts, :serializer, :stringify_keys)
    converter = Keyword.get(opts, :converter, &Recase.to_camel/1)

    env
    |> request(serializer, converter)
    |> Tesla.run(next)
    |> response(serializer, &Recase.to_snake/1)
  end

  defp request(%{body: nil} = env, _serializer, _converter) do
    env
  end

  defp request(%{body: body} = env, serializer, converter) do
    %{env | body: converter(body, serializer, converter)}
  end

  defp response({:ok, %{body: nil}} = env, _serializer, _converter) do
    env
  end

  defp response({:ok, env}, serializer, converter) do
    env = Map.update!(env, :body, &converter(&1, serializer, converter))

    {:ok, env}
  end

  defp response({:error, error}, _serializer, _converter) do
    {:error, error}
  end

  defp converter(data, serializer, converter) do
    apply(Enumerable, serializer, [data, converter])
  end
end
