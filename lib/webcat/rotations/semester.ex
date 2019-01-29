defmodule WebCAT.Rotations.Semester do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Validators
  alias WebCAT.Accounts.User

  schema "semesters" do
    field(:title, :string)
    field(:start_date, :date)
    field(:end_date, :date)

    belongs_to(:classroom, WebCAT.Rotations.Classroom)
    has_many(:sections, WebCAT.Rotations.Section)

    timestamps()
  end

  @required ~w(title start_date end_date classroom_id)a
  @optional ~w()a

  @doc """
  Build a changeset for a semester
  """
  def changeset(semester, attrs \\ %{}) do
    semester
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_dates_after(:start_date, :end_date)
    |> foreign_key_constraint(:classroom_id)
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
