defmodule WebCAT.Feedback.Observation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "observations" do
    field(:content, :string)
    field(:type, :string)

    belongs_to(:category, WebCAT.Feedback.Category)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    has_many(:notes, WebCAT.Feedback.Note)
    has_many(:feedback, WebCAT.Feedback.Feedback)

    timestamps()
  end

  @doc """
  Create a changeset for an observation
  """
  def changeset(observation, attrs \\ %{}) do
    observation
    |> cast(attrs, ~w(content type category_id rotation_group_id)a)
    |> validate_required(~w(content type category_id rotation_group_id)a)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:rotation_group_id)
  end
end
