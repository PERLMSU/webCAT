defmodule WebCAT.Rotations.Rotation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rotations" do
    field(:start_week, :integer)
    field(:end_week, :integer)

    belongs_to(:classroom, WebCAT.Rotations.Classroom)
    has_many(:rotation_groups, WebCAT.Rotations.RotationGroup)

    timestamps()
  end

  @doc """
  Build a changeset for a rotation
  """
  def changeset(rotation, attrs \\ %{}) do
    rotation
    |> cast(attrs, ~w(start_week end_week classroom_id)a)
    |> validate_required(~w(start_week end_week classroom_id)a)
    |> foreign_key_constraint(:classroom_id)
  end
end
