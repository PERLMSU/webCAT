defmodule WebCATWeb.ViewHelpers do
  def timestamps_format(map) when is_map(map) do
    map
    |> case do
      %{inserted_at: _} -> Map.update!(map, :inserted_at, &Timex.format!(&1, "{ISO:Extended}"))
      map -> map
    end
    |> case do
      %{updated_at: _} -> Map.update!(map, :updated_at, &Timex.format!(&1, "{ISO:Extended}"))
      map -> map
    end
  end
end
