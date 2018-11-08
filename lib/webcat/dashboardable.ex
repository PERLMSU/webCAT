defmodule WebCAT.Dashboardable do
  @moduledoc """
  Behavior for things that should be able to be dashboard items
  """

  @callback title_for(Ecto.Schema.t()) :: String.t()
  @callback table_fields() :: [atom]
  @callback display(Ecto.Schema.t()) :: Map.t()

  def title_for(implementation, data) do
    implementation.title_for(data)
  end

  def table_fields(implementation) do
    implementation.table_fields()
  end

  def display(implementation, data) do
    implementation.display(data)
  end
end
