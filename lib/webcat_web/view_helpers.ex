defmodule WebCATWeb.ViewHelpers do
  def timestamps_format(map) when is_map(map) do
    map
    |> update_if_exists(:inserted_at, &DateTime.to_unix/1)
    |> update_if_exists(:updated_at, &DateTime.to_unix/1)
  end

  defp update_if_exists(map, key, fun) do
    if Map.has_key?(map, key), do: Map.update!(map, key, fun), else: map
  end
end
