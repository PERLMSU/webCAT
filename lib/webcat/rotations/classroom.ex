defmodule WebCAT.Rotations.Classroom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classrooms" do
    field(:course_code, :string)
    field(:section, :string)
    field(:description, :string)

    belongs_to(:semester, WebCAT.Rotations.Semester)
    has_many(:rotations, WebCAT.Rotations.Rotation)
    has_many(:students, WebCAT.Rotations.Student)
    many_to_many(:instructors, WebCAT.Accounts.User, join_through: "user_classrooms")

    timestamps()
  end

  @required ~w(course_code section semester_id)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a classroom
  """
  def changeset(classroom, attrs \\ %{}) do
    classroom
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:semester_id)
  end

  def title_for(classroom) do
    "#{classroom.course_code} - #{classroom.section}"
  end
end
