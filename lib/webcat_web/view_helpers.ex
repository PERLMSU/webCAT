defmodule WebCATWeb.ViewHelpers do
  def timestamps_format(map) when is_map(map) do
    map
    |> update_if_exists(:inserted_at, &to_unix/1)
    |> update_if_exists(:updated_at, &to_unix/1)
  end

  defp to_unix(datetime) do
    case datetime do
      %DateTime{} -> DateTime.to_unix(datetime)
      %NaiveDateTime{} -> DateTime.from_naive!(datetime, "Etc/UTC") |> DateTime.to_unix()
    end
  end

  defp update_if_exists(map, key, fun) do
    if Map.has_key?(map, key), do: Map.update!(map, key, fun), else: map
  end
end
