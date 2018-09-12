defmodule WebCAT.Feedback.Explanation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "explanations" do
    field(:content, :string)

    belongs_to(:observation, WebCAT.Feedback.Observation)

    timestamps()
  end

  @doc """
  Create a changeset for an explanation
  """
  def changeset(explanation, attrs \\ %{}) do
    explanation
    |> cast(attrs, ~w(content feedback_id)a)
    |> validate_required(~w(content feedback_id)a)
    |> foreign_key_constraint(:feedback_id)
  end
end
