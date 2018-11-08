defmodule WebCAT.Rotations.Rotation do
  @behaviour WebCAT.Dashboardable
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Validators
  alias WebCAT.Accounts.User

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
    |> cast(attrs, ~w(start_date end_date rotation_id)a)
    |> validate_required(~w(start_date end_date rotation_id)a)
    |> validate_dates_after(:start_date, :end_date)
    |> foreign_key_constraint(:rotation_id)
  end

  def title_for(rotation), do:  "Rotation #{Timex.format!(rotation.start_date, "{M} {D}, {YYYY}")} - #{Timex.format!(rotation.end_date, "{M} {D}, {YYYY}")}"

  def table_fields(), do: ~w(start_date end_date)a

  def display(rotation) do
    rotation
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> Map.update!(:start_date, fn value ->
      "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
        Timex.format!(value, "{relative}", :relative)
      })"
    end)
    |> Map.update!(:end_date, fn value ->
      "#{Timex.format!(value, "{Mfull} {D}, {YYYY}")} (#{
        Timex.format!(value, "{relative}", :relative)
      })"
    end)
  end

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list_rotations show_rotation)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_rotation update_rotation delete_rotation)a,
      do: true

  def authorize(_, _, _), do: false
end
