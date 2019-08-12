defmodule WebCAT.Accounts.User do
  @moduledoc """
  Schema for user accounts
  """
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup}
  alias Terminator.{Performer, Role}
  alias WebCAT.Accounts.User
  alias WebCAT.Repo

  schema "users" do
    field(:email, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    field(:middle_name, :string)
    field(:nickname, :string)
    field(:active, :boolean, default: true)

    belongs_to(:performer, Terminator.Performer)

    many_to_many(:classrooms, Classroom, join_through: "classroom_users", on_replace: :delete)
    many_to_many(:semesters, Semester, join_through: "semester_users", on_replace: :delete)
    many_to_many(:sections, Section, join_through: "section_users", on_replace: :delete)
    many_to_many(:rotations, Rotation, join_through: "rotation_users", on_replace: :delete)

    many_to_many(:rotation_groups, RotationGroup,
      join_through: "rotation_group_users",
      on_replace: :delete
    )

    has_many(:notifications, WebCAT.Accounts.Notification)

    # For student feedback
    # field(:feedback, {:array, :map}, virtual: true)

    # For role assignment TODO: Needs better solution
    has_many(:roles, through: ~w(performer roles)a)

    timestamps(type: :utc_datetime)
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
    |> put_roles(Map.get(attrs, "roles"))
    |> put_classrooms(Map.get(attrs, "classrooms"))
  end

  defp put_performer(%{valid?: true} = changeset) do
    case get_field(changeset, :performer_id) do
      nil -> put_assoc(changeset, :performer, Repo.insert!(%Terminator.Performer{}))
      _ -> changeset
    end
  end

  defp put_performer(changeset), do: changeset

  defp put_roles(%{valid?: true} = changeset, roles) when is_list(roles) do
    case get_field(changeset, :performer) do
      nil ->
        changeset

      performer ->
        performer
        |> Repo.preload(~w(roles)a)
        |> Performer.changeset()
        |> put_assoc(:roles, Repo.all(from(r in Role, where: r.id in ^roles)))
        |> Repo.update()

        changeset
    end
  end

  defp put_roles(changeset, _), do: changeset

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


  @doc """
  Get all of the rotation groups that the user is in
  """
  def rotation_groups(user_id) do
    from(rg in RotationGroup,
      left_join: u in assoc(rg, :users),
      left_join: u2 in assoc(rg, :users),
      where: u.id == ^user_id,
      left_join: r in assoc(u2, :roles),
      preload:  [:rotation, users: {u2, roles: r}])
    |> Repo.all()
  end
end
