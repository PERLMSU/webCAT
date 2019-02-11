defmodule WebCAT.Rotations.Student do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Accounts.{User, Groups}
  alias WebCAT.Rotations.{Section, RotationGroup}
  alias WebCAT.Repo

  schema "students" do
    field(:email, :string)

    belongs_to(:user, User)
    many_to_many(:rotation_groups, WebCAT.Rotations.RotationGroup, join_through: "student_groups")
    many_to_many(:sections, WebCAT.Rotations.Section, join_through: "student_sections")

    timestamps()
  end

  @required ~w(user_id)a
  @optional ~w(email)a

  @doc """
  Build a changeset for a student
  """
  def changeset(student, attrs \\ %{}) do
    student
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:email)
    |> put_rotation_groups(Map.get(attrs, "rotation_groups"))
    |> put_sections(Map.get(attrs, "sections"))
  end

  defp put_rotation_groups(%{valid?: true} = changeset, rotation_groups)
       when is_list(rotation_groups) do
    put_assoc(
      changeset,
      :rotation_groups,
      Repo.all(from(r in RotationGroup, where: r.id in ^rotation_groups))
    )
  end

  defp put_rotation_groups(changeset, _), do: changeset

  defp put_sections(%{valid?: true} = changeset, sections) when is_list(sections) do
    put_assoc(changeset, :sections, Repo.all(from(s in Section, where: s.id in ^sections)))
  end

  defp put_sections(changeset, _), do: changeset

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{groups: groups}, _)
      when action in ~w(create update delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  def authorize(_, _, _), do: false
end
