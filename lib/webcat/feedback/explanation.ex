defmodule WebCAT.Feedback.Explanation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "explanations" do
    field(:content, :string)

    belongs_to(:feedback, WebCAT.Feedback.Feedback)

    timestamps(type: :utc_datetime)
  end

  @required ~w(content feedback_id)a

  @doc """
  Create a changeset for an explanation
  """
  def changeset(feedback, attrs \\ %{}) do
    feedback
    |> cast(attrs, @required)
    |> validate_required(@required)
    |> foreign_key_constraint(:feedback_id)
  end
end
