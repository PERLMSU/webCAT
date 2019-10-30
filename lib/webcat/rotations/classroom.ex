defmodule WebCAT.Rotations.Classroom do
  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User
  import WebCAT.Repo.Utils

  schema "classrooms" do
    field(:course_code, :string)
    field(:name, :string)
    field(:description, :string)

    has_many(:sections, WebCAT.Rotations.Section)
    many_to_many(:users, User, join_through: "classroom_users", on_replace: :delete)

    many_to_many(:categories, WebCAT.Feedback.Category,
      join_through: "classroom_categories",
      on_replace: :delete
    )

    timestamps(type: :utc_datetime)
  end

  @required ~w(course_code name)a
  @optional ~w(description)a

  @doc """
  Build a changeset for a classroom
  """
  def changeset(classroom, attrs \\ %{}) do
    classroom
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(:course_code, name: :classrooms_course_code_index)
    |> put_relation(:users, WebCAT.Accounts.User, Map.get(attrs, "users", []))
    |> put_relation(:categories, WebCAT.Feedback.Category, Map.get(attrs, "categories", []))
  end
end
