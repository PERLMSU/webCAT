defmodule WebCAT.Feedback.Category do
  use Ecto.Schema
  import Ecto.Changeset
  import WebCAT.Repo.Utils

  schema "categories" do
    field(:name, :string)
    field(:description, :string)

    belongs_to(:parent_category, WebCAT.Feedback.Category)
    has_many(:sub_categories, WebCAT.Feedback.Category, foreign_key: :parent_category_id)
    has_many(:observations, WebCAT.Feedback.Observation, foreign_key: :category_id)

    many_to_many(:classrooms, WebCAT.Rotations.Classroom, join_through: "classroom_categories", on_replace: :delete)

    timestamps(type: :utc_datetime)
  end

  @required ~w(name)a
  @optional ~w(description parent_category_id)a

  @doc """
  Create a changeset for a category
  """
  def changeset(category, attrs \\ %{}) do
    category
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> foreign_key_constraint(:parent_category_id)
    |> unique_constraint(:name)
    |> put_relation(:classrooms, WebCAT.Rotations.Classroom, Map.get(attrs, "classrooms", []))
  end
end
