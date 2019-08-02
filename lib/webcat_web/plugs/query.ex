defmodule WebCATWeb.QueryHelpers do
  @moduledoc """
  Helpers for parsing query data
  """

  def filter(params, filter_fields) do
    params
    |> Map.take(filter_fields)
    |> Map.to_list()
    |> Enum.map(fn {key, val} -> {String.to_atom(key), val} end)
  end
end
