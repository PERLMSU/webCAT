defmodule WebCAT.Rotations.Rotation do
  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Validators

  schema "rotations" do
    field(:start_date, :date)
    field(:end_date, :date)

    belongs_to(:classroom, WebCAT.Rotations.Classroom)
    has_many(:rotation_groups, WebCAT.Rotations.RotationGroup)

    timestamps()
  end

  @doc """
  Build a changeset for a rotation
  """
  def changeset(rotation, attrs \\ %{}) do
    rotation
    |> cast(attrs, ~w(start_date end_date classroom_id)a)
    |> validate_required(~w(start_date end_date classroom_id)a)
    |> validate_dates_after(:start_date, :end_date)
    |> foreign_key_constraint(:classroom_id)
  end
end
