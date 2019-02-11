defmodule WebCAT.Rotations.RotationGroup do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Accounts.{User, Groups}
  alias WebCAT.Rotations.Student
  alias WebCAT.Repo

  schema "rotation_groups" do
    field(:number, :integer)
    field(:description, :string)

    belongs_to(:rotation, WebCAT.Rotations.Rotation)

    many_to_many(:students, WebCAT.Rotations.Student, join_through: "student_groups")
    many_to_many(:users, WebCAT.Accounts.User, join_through: "rotation_group_users")

    timestamps()
  end

  @required ~w(number rotation_id)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a rotation group
  """
  def changeset(group, attrs \\ %{}) do
    group
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:rotation_id)
    |> put_users(Map.get(attrs, "users"))
    |> put_students(Map.get(attrs, "students"))
  end

  defp put_users(%{valid?: true} = changeset, users) when is_list(users) do
    put_assoc(changeset, :users, Repo.all(from(u in User, where: u.id in ^users)))
  end

  defp put_users(changeset, _), do: changeset

  defp put_students(%{valid?: true} = changeset, students) when is_list(students) do
    put_assoc(changeset, :students, Repo.all(from(s in Student, where: s.id in ^students)))
  end

  defp put_students(changeset, _), do: changeset

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{groups: groups}, _)
      when action in ~w(create update delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  def authorize(_, _, _), do: false
end
