defmodule WebCAT.Rotations.Classroom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classrooms" do
    field(:course_code, :string)
    field(:section, :string)
    field(:description, :string)

    belongs_to(:semester, InTheDoor.Rotations.Semester)
    has_many(:rotations, InTheDoor.Rotations.Rotation)
    has_many(:students, InTheDoor.Rotations.Student)

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
