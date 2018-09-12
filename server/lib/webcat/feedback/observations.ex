defmodule WebCAT.Feedback.Observations do
  @moduledoc """
  Helper functions for working with observations
  """

  alias WebCAT.Repo
  alias WebCAT.Feedback.{Note, Explanation}

  import Ecto.Query

  def notes(observation_id, options \\ []) do
    Note
    |> where([n], n.observation_id == ^observation_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def explanations(observation_id, options \\ []) do
    Explanation
    |> where([e], e.observation_id == ^observation_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
