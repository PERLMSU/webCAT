defmodule WebCAT.Rotations.RotationGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "rotation_groups" do
    field(:description, :string)
    field(:number, :integer)

    belongs_to(:rotation, WebCAT.Rotations.Rotation)
    belongs_to(:instructor, WebCAT.Accounts.User, foreign_key: :instructor_id)

    timestamps()
  end

  @doc """
  Build a changeset for a rotation group
  """
  def changeset(group, attrs \\ %{}) do
    group
    |> cast(attrs, ~w(description number rotation_id instructor_id)a)
    |> validate_required(~w(number rotation_id instructor_id)a)
    |> foreign_key_constraint(:rotation_id)
    |> foreign_key_constraint(:instructor_id)
  end
end
