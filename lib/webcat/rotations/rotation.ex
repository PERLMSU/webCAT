defmodule WebCAT.Rotations.Rotation do
  @behaviour WebCAT.Dashboardable
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

  def title_for(rotation), do:  "Rotation #{Timex.format!(rotation.start_date, "{M} {D}, {YYYY}")} - #{Timex.format!(rotation.end_date, "{M} {D}, {YYYY}")}"

  def table_fields(), do: ~w(start_date end_date)a

  def display(rotation) do
    rotation
    |> Map.from_struct()
    |> Map.take(~w(start_date end_date)a)
    |> Map.update!(:start_date, fn value ->
      if Timex.is_valid?(value) do
        "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
          Timex.format!(value, "{relative}", :relative)
        })"
      end
    end)
    |> Map.update!(:end_date, fn value ->
      if Timex.is_valid?(value) do
        "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
          Timex.format!(value, "{relative}", :relative)
        })"
      end
    end)
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
