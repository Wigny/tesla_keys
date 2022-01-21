defmodule TeslaKeys do
  @moduledoc """
  Group middleware useful to manipulate body keys

  ## Examples
  ```
  defmodule MyClient do
    use Tesla

    plug TeslaKeys.Middleware.Case,
      encoder: &Recase.to_camel/1,
      serializer: &Recase.Enumerable.atomize_keys/2

    plug TeslaKeys.Middleware.Remapper, keys: %{"body" => "content"}
    plug Tesla.Middleware.JSON
  end

  MyClient.put("https://jsonplaceholder.typicode.com/posts/1", %{
    title: "foo",
    content: "bar",
    user_id: 1
  })
  ```
  """

  defguard is_enum(data) when is_map(data) or is_list(data)
end
