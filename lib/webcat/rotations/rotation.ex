defmodule WebCAT.Rotations.Rotation do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Validators
  alias WebCAT.Accounts.User

  schema "rotations" do
    field(:number, :integer)
    field(:description, :string)
    field(:end_date, :date)
    field(:start_date, :date)

    belongs_to(:section, WebCAT.Rotations.Section)
    has_many(:rotation_groups, WebCAT.Rotations.RotationGroup)

    timestamps()
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

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create update delete)a,
      do: true

  def authorize(_, _, _), do: false
end
