defmodule TeslaKeys do
  @moduledoc """
  Aggregate of useful middlewares to manipulate body keys

  ## Examples
  ```
  defmodule MyClient do
    use Tesla

    plug Tesla.Middleware.BaseUrl, "https://jsonplaceholder.typicode.com/"
    plug TeslaKeys.Middleware.Remapper, keys: [body: :content]
    plug TeslaKeys.Middleware.Case, encoder: &Recase.to_camel/1, serializer: &Recase.Enumerable.atomize_keys/2
    plug Tesla.Middleware.JSON
  end

  MyClient.put("/posts/1", %{title: "foo", content: "bar", user_id: 1})
  ```
  """

  defguard is_enum(data) when is_map(data) or is_list(data)
end
