defmodule WebCAT.Feedback.Categories do
  @moduledoc """
  Helper functions for working with categories
  """

  alias WebCAT.Repo
  alias WebCAT.Feedback.Observation

  import Ecto.Query

  @doc """
  Get all observations for a category
  """
  @spec observations(integer, Keyword.t) :: [Observation.t]
  def observations(category_id, options \\ []) do
    Observation
    |> where([o], o.category_id == ^category_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
