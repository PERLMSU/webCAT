defmodule WebCATWeb.ViewHelpers do
  def timestamps_format(map) when is_map(map) do
    map
    |> case do
      %{inserted_at: _} -> Map.update!(map, :inserted_at, &DateTime.to_unix/1)
      Map -> map
    end
    |> case do
      %{updated_at: _} -> Map.update!(map, :updated_at, &DateTime.to_unix/1)
      map -> map
    end
  end
end
