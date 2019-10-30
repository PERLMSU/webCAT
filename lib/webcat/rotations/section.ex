defmodule WebCAT.Rotations.Section do
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User
  alias WebCAT.Rotations.{Semester, Classroom, Rotation}
  import WebCAT.Repo.Utils

  schema "sections" do
    field(:number, :string)
    field(:description, :string)

    belongs_to(:semester, Semester)
    belongs_to(:classroom, Classroom)
    has_many(:rotations, Rotation)
    many_to_many(:users, User, join_through: "section_users", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(number semester_id classroom_id)a
  @optional ~w(description)a

  def changeset(section, attrs \\ %{}) do
    section
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:semester_id)
    |> put_relation(:users, User, Map.get(attrs, "users", []))
  end
end
