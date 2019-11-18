defmodule WebCAT.Rotations.Rotation do
  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Validators

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
    fixed_attrs =
      attrs
      |> fix_posix("start_date")
      |> fix_posix("end_date")

    rotation
    |> cast(fixed_attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_dates_after(:start_date, :end_date)
    |> foreign_key_constraint(:section_id)
  end

  defp fix_posix(map, key) do
    if Map.has_key?(map, key) do
      if is_integer(Map.get(map, key)) do
        Map.update!(map, key, fn val ->
          Timex.from_unix(val, :millisecond)
        end)
      else
        map
      end
    else
      map
    end
  end
end
