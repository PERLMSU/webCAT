defmodule WebCAT.Accounts.User do
  @moduledoc """
  Schema for user accounts
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Rotations.{Classroom, Semester, Section, Rotation, RotationGroup}
  import WebCAT.Repo.Utils

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
    |> put_relation(:classrooms, Classroom, Map.get(attrs, "classrooms", []))
    |> put_relation(:semesters, Semester, Map.get(attrs, "semesters", []))
    |> put_relation(:sections, Section, Map.get(attrs, "sections", []))
    |> put_relation(:rotations, Rotation, Map.get(attrs, "rotations", []))
    |> put_relation(:rotation_groups, RotationGroup, Map.get(attrs, "rotation_groups", []))
  end
end
