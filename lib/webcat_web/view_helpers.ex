defmodule WebCATWeb.ViewHelpers do
  def to_unix_millis(datetime) do
    case datetime do
      %Date{} -> Timex.to_unix(datetime) * 1000
      %DateTime{} -> Timex.to_unix(datetime) * 1000
      %NaiveDateTime{} -> DateTime.from_naive!(datetime, "Etc/UTC") |> Timex.to_unix() |> Kernel.* 1000
    end
  end

  defp update_if_exists(map, key, fun) do
    if Map.has_key?(map, key), do: Map.update!(map, key, fun), else: map
  end
end
