defmodule WebCAT.Rotations.Classroom do
  @behaviour WebCAT.Dashboardable
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

  schema "classrooms" do
    field(:course_code, :string)
    field(:title, :string)
    field(:description, :string)

    has_many(:semesters, WebCAT.Rotations.Semester)
    many_to_many(:users, WebCAT.Accounts.User, join_through: "user_classrooms")

    timestamps()
  end

  @required ~w(course_code title)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a classroom
  """
  def changeset(classroom, attrs \\ %{}) do
    classroom
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
  end

  # Dashboardable behavior

  def title_for(classroom), do: "#{classroom.course_code} - #{classroom.title}"

  def table_fields(), do: ~w(course_code title description)a

  def display(classroom) do
    classroom
    |> Map.from_struct()
    |> Map.take(~w(course_code title description)a)
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
