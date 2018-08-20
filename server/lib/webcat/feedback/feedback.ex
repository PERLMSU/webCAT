defmodule WebCAT.Feedback.Feedback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feedback" do
    field(:content, :string)

    belongs_to(:observation, WebCAT.Feedback.Observation)
    has_many(:explanations, WebCAT.Feedback.Explanation)

    timestamps()
  end

  @doc """
  Create a changeset for feedback
  """
  def changeset(feedback, attrs \\ %{}) do
    feedback
    |> cast(attrs, ~w(content observation_id)a)
    |> validate_required(~w(content observation_id)a)
    |> foreign_key_constraint(:observation_id)
  end
end
