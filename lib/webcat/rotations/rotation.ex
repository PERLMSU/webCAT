defmodule WebCAT.Rotations.Rotation do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  import WebCAT.Validators
  alias WebCAT.Repo

  schema "rotations" do
    field(:number, :integer)
    field(:description, :string)
    field(:start_date, :date)
    field(:end_date, :date)

    belongs_to(:section, WebCAT.Rotations.Section)
    has_many(:rotation_groups, WebCAT.Rotations.RotationGroup)

    timestamps(type: :utc_datetime)
  end

  @required ~w(number start_date end_date section_id)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a rotation
  """
  def changeset(rotation, attrs \\ %{}) do
    rotation
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_dates_after(:start_date, :end_date)
    |> foreign_key_constraint(:section_id)
  end
end
