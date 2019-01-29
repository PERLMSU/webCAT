defmodule WebCAT.Accounts.User do
  @behaviour Bodyguard.Policy

  @moduledoc """
  Schema for user accounts
  """
  use Ecto.Schema
  alias Comeonin.Pbkdf2
  import Ecto.Changeset
  alias WebCAT.Accounts.User
  alias WebCAT.Rotations.{Classroom, RotationGroup, Section}
  alias WebCAT.Repo
  import Ecto.Query

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:email, :string)
    field(:username, :string)
    field(:password, :string)
    field(:nickname, :string)
    field(:bio, :string)
    field(:active, :boolean, default: true)
    field(:role, :string, default: "assistant")

    many_to_many(:classrooms, Classroom, join_through: "user_classrooms")
    many_to_many(:sections, Section, join_through: "user_sections")
    many_to_many(:rotation_groups, RotationGroup, join_through: "rotation_group_users")
    has_many(:notifications, WebCAT.Accounts.Notification)

    timestamps()
  end

  @required ~w(first_name last_name email username password role)a
  @optional ~w(middle_name nickname bio active)a

  @doc """
  Build a changeset for a user
  """
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_format(:email, ~r/(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)/)
    # letters and numbers up to 24 characters
    |> validate_format(:username, ~r/^[\w\d]{1,24}$/)
    |> validate_inclusion(:role, ~w(assistant instructor admin))
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> put_classrooms(Map.get(attrs, "classrooms"))
    |> put_sections(Map.get(attrs, "sections"))
    |> put_rotation_groups(Map.get(attrs, "rotation_groups"))
  end

  @doc """
  Build a changeset for creating a user
  """
  def create_changeset(user, attrs \\ %{}) do
    changeset(user, attrs)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Pbkdf2.hashpwsalt(password))
  end

  defp put_pass_hash(changeset), do: changeset

  defp put_classrooms(%{valid?: true} = changeset, classrooms) when is_list(classrooms) do
    put_assoc(changeset, :classrooms, Repo.all(from(c in Classroom, where: c.id in ^classrooms)))
  end

  defp put_classrooms(changeset, _), do: changeset

  defp put_sections(%{valid?: true} = changeset, sections) when is_list(sections) do
    put_assoc(changeset, :sections, Repo.all(from(s in Section, where: s.id in ^sections)))
  end

  defp put_sections(changeset, _), do: changeset

  defp put_rotation_groups(%{valid?: true} = changeset, rotation_groups)
       when is_list(rotation_groups) do
    put_assoc(
      changeset,
      :rotation_groups,
      Repo.all(from(r in RotationGroup, where: r.id in ^rotation_groups))
    )
  end

  defp put_rotation_groups(changeset, _), do: changeset

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create update delete)a,
      do: true

  def authorize(action, %User{role: "admin"}, %User{role: "instructor"})
      when action in ~w(update delete)a,
      do: true

  def authorize(action, %User{role: "admin"}, %User{role: "instructor"})
      when action in ~w(list_notifications list_classrooms list_rotation_groups)a,
      do: true

  def authorize(action, %User{id: id}, %User{id: id})
      when action in ~w(update list_notifications list_classrooms list_rotation_groups)a,
      do: true

  def authorize(_, _, _), do: false
end
