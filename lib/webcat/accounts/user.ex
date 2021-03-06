defmodule WebCAT.Accounts.User do
  @moduledoc """
  Schema for user accounts
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup}
  alias Terminator.{Performer, Role}

  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:nickname, :string)
    field(:active, :boolean, default: true)

    belongs_to(:performer, Terminator.Performer)

    many_to_many(:classrooms, Classroom, join_through: "classroom_users")
    many_to_many(:semesters, Semester, join_through: "semester_users")
    many_to_many(:sections, Section, join_through: "section_users")
    many_to_many(:rotations, Rotation, join_through: "rotation_users")
    many_to_many(:rotation_groups, RotationGroup, join_through: "rotation_group_users")

    has_many(:notifications, WebCAT.Accounts.Notification)

    # For student feedback
    # field(:feedback, {:array, :map}, virtual: true)

    timestamps()
  end

  @required ~w(email first_name last_name)a
  @optional ~w(middle_name nickname active performer_id)a

  @doc """
  Build a changeset for a user
  """
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> put_performer()
  end

  defp put_performer(%{valid?: true} = changeset) do
    case get_field(changeset, :performer_id) do
      nil -> put_assoc(changeset, :performer, %Terminator.Performer{})
      _ -> changeset
    end
  end

  defp put_performer(changeset), do: changeset

  @doc """
  Partition a list of users into a map keyed by their role.
  Keys are strings.
  """
  def by_role(users) when is_list(users) do
    Enum.reduce(users, %{}, fn user, acc ->
      user.performer.roles
      |> Enum.map(&Map.get(&1, :identifier))
      |> Enum.reject(&is_nil/1)
      |> Enum.reduce(acc, fn role, nested_acc ->
        Map.update(nested_acc, role, [user], fn value ->
          [user | value]
        end)
      end)
    end)
  end
end
