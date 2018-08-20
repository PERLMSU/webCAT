defmodule WebCAT.Rotations.Semester do
  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Validators

  schema "semesters" do
    field(:start_date, :date)
    field(:end_date, :date)
    field(:title, :string)

    has_many(:classrooms, WebCAT.Rotations.Classroom)

    timestamps()
  end

  @doc """
  Build a changeset for a semester
  """
  def changeset(semester, attrs \\ %{}) do
    semester
    |> cast(attrs, ~w(start_date end_date title)a)
    |> validate_required(~w(start_date end_date title)a)
    |> validate_dates_after(:start_date, :end_date)
  end
end
