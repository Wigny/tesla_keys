defmodule TeslaCase do
  @moduledoc false

  defguard is_enum(data) when is_map(data) or is_list(data)
end
