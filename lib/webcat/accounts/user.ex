defmodule WebCAT.Accounts.User do
  @behaviour Bodyguard.Policy

  @moduledoc """
  Schema for user accounts
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.{Group, Groups}
  alias WebCAT.Rotations.{Classroom, RotationGroup}
  alias WebCAT.Repo
  import Ecto.Query

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:nickname, :string)
    field(:active, :boolean, default: true)

    many_to_many(:classrooms, Classroom, join_through: "user_classrooms")
    many_to_many(:rotation_groups, RotationGroup, join_through: "rotation_group_users")
    many_to_many(:groups, Group, join_through: "user_groups")
    has_many(:notifications, WebCAT.Accounts.Notification)

    timestamps()
  end

  @required ~w(first_name last_name)a
  @optional ~w(middle_name nickname active)a

  @doc """
  Build a changeset for a user
  """
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> put_classrooms(Map.get(attrs, "classrooms"))
    |> put_rotation_groups(Map.get(attrs, "rotation_groups"))
    |> put_groups(Map.get(attrs, "groups"))
  end

  defp put_classrooms(%{valid?: true} = changeset, classrooms) when is_list(classrooms) do
    put_assoc(changeset, :classrooms, Repo.all(from(c in Classroom, where: c.id in ^classrooms)))
  end

  defp put_classrooms(changeset, _), do: changeset

  defp put_rotation_groups(%{valid?: true} = changeset, rotation_groups)
       when is_list(rotation_groups) do
    put_assoc(
      changeset,
      :rotation_groups,
      Repo.all(from(r in RotationGroup, where: r.id in ^rotation_groups))
    )
  end

  defp put_rotation_groups(changeset, _), do: changeset

  defp put_groups(%{valid?: true} = changeset, groups)
       when is_list(groups) do
    put_assoc(
      changeset,
      :groups,
      Repo.all(from(g in Group, where: g.id in ^groups))
    )
  end

  defp put_groups(changeset, _), do: changeset

  # Policy behavior

  def authorize(action, %__MODULE__{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %__MODULE__{groups: groups}, _)
      when action in ~w(create update delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  def authorize(action, %__MODULE__{id: id}, %__MODULE__{id: id})
      when action in ~w(update notifications)a,
      do: true

  def authorize(_, _, _), do: false
end
