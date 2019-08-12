defmodule WebCAT.Feedback.Feedback do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feedback" do
    field(:content, :string)

    belongs_to(:observation, WebCAT.Feedback.Observation)
    has_many(:explanations, WebCAT.Feedback.Explanation)

    timestamps(type: :utc_datetime)
  end

  @required ~w(content observation_id)a

  @doc """
  Create a changeset for an feedback
  """
  def changeset(feedback, attrs \\ %{}) do
    feedback
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:observation_id)
  end
end
