defmodule WebCAT.Rotations.Classroom do
  @behaviour WebCAT.Dashboardable
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

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

  # Dashboardable behavior

  def title_for(classroom), do: "#{classroom.course_code} - #{classroom.section}"

  def table_fields(), do: ~w(course_code section description)a

  def display(classroom) do
    classroom
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
  end

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list_classrooms show_classroom)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_classroom update_classroom delete_classroom)a,
      do: true

  def authorize(_, _, _), do: false
end
