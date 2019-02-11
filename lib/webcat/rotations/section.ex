defmodule WebCAT.Rotations.Section do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Accounts.{User, Groups}
  alias WebCAT.Rotations.Student
  alias WebCAT.Repo

  schema "sections" do
    field(:number, :string)
    field(:description, :string)

    belongs_to(:semester, WebCAT.Rotations.Semester)
    has_many(:rotations, WebCAT.Rotations.Rotation)
    many_to_many(:students, WebCAT.Rotations.Student, join_through: "student_sections")

    timestamps()
  end

  @required ~w(number semester_id)a
  @optional ~w(description)a

  def changeset(section, attrs \\ %{}) do
    section
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:semester_id)
    |> put_students(Map.get(attrs, "students"))
  end

  defp put_students(%{valid?: true} = changeset, students) when is_list(students) do
    put_assoc(changeset, :students, Repo.all(from(s in Student, where: s.id in ^students)))
  end

  defp put_students(changeset, _), do: changeset

  # Policy behaviour

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{groups: groups}, _)
      when action in ~w(create update delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  @spec authorize(any(), any(), any()) :: false
  def authorize(_, _, _), do: false
end
