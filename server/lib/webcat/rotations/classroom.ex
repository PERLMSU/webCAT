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

  @doc """
  Build a changeset for a classroom
  """
  def changeset(classroom, attrs \\ %{}) do
    classroom
    |> cast(attrs, ~w(course_code section description semester_id)a)
    |> validate_required(~w(course_code section semester_id)a)
    |> foreign_key_constraint(:semester_id)
  end
end
