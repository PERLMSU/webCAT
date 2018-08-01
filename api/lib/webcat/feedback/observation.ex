defmodule WebCAT.Feedback.Observation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "observations" do
    field(:content, :string)
    field(:feedback, :string)
    field(:explanation, :string)
    field(:type, :string)

    belongs_to(:category, WebCAT.Feedback.Category)
    belongs_to(:rotation_group, WebCAT.Rotations.RotationGroup)

    timestamps()
  end

  @doc """
  Create a changeset for a observation
  """
  def changeset(observation, attrs \\ %{}) do
    observation
    |> cast(attrs, ~w(content feedback explanation type category_id rotation_group_id)a)
    |> validate_required(~w(content feedback explanation type category_id rotation_group_id)a)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:parent_category_id)
  end
end
