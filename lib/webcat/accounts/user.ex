defmodule WebCAT.Accounts.User do
  @moduledoc """
  Schema for user accounts
  """
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup}
  alias WebCAT.Accounts.User
  alias WebCAT.Repo

  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:nickname, :string)
    field(:active, :boolean, default: true)
    field(:role, :string)


    many_to_many(:classrooms, Classroom, join_through: "classroom_users", on_replace: :delete)
    many_to_many(:semesters, Semester, join_through: "semester_users", on_replace: :delete)
    many_to_many(:sections, Section, join_through: "section_users", on_replace: :delete)
    many_to_many(:rotations, Rotation, join_through: "rotation_users", on_replace: :delete)
    many_to_many(:rotation_groups, RotationGroup,
      join_through: "rotation_group_users",
      on_replace: :delete
    )

    has_many(:notifications, WebCAT.Accounts.Notification)

    timestamps(type: :utc_datetime)
  end

  @required ~w(email first_name last_name role)a
  @optional ~w(middle_name nickname active)a

  @doc """
  Build a changeset for a user
  """
  def changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:email)
    |> validate_inclusion(:role, ~w(admin faculty teaching_assistant learning_assistant student))
    |> put_classrooms(Map.get(attrs, "classrooms"))
  end

  defp put_classrooms(%{valid?: true} = changeset, classrooms) when is_list(classrooms) do
    ids =
      classrooms
      |> Enum.map(fn classroom ->
        case classroom do
          %{id: id} ->
            id

          id when is_integer(id) ->
            id

          id when is_binary(id) ->
            String.to_integer(id)

          _ ->
            nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    # Heed the warning in draft.ex before copying this behavior
    changeset
    |> Map.put(:data, Map.put(changeset.data, :classrooms, []))
    |> put_assoc(:classrooms, Repo.all(from(c in Classroom, where: c.id in ^ids)))
  end

  defp put_classrooms(changeset, _), do: changeset
end
