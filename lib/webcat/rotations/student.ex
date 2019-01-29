defmodule WebCAT.Rotations.Student do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  alias WebCAT.Accounts.User
  alias WebCAT.Rotations.{Section, RotationGroup}
  alias WebCAT.Repo

  schema "students" do
    field(:first_name, :string)
    field(:middle_name, :string)
    field(:last_name, :string)
    field(:description, :string)
    field(:email, :string)

    many_to_many(:rotation_groups, WebCAT.Rotations.RotationGroup, join_through: "student_groups")
    many_to_many(:sections, WebCAT.Rotations.Section, join_through: "student_sections")
    has_many(:notes, WebCAT.Feedback.Note)

    timestamps()
  end

  @required ~w(first_name last_name)a
  @optional ~w(middle_name description email)a

  @doc """
  Build a changeset for a student
  """
  def changeset(student, attrs \\ %{}) do
    student
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:classroom_id)
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

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create update delete)a,
      do: true

  def authorize(_, _, _), do: false
end
