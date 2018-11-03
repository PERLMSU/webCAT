defmodule WebCAT.Feedback.Category do
  use Ecto.Schema
  import Ecto.Changeset

  schema "categories" do
    field(:name, :string)
    field(:description, :string)

    belongs_to(:parent_category, WebCAT.Feedback.Category)
    has_many(:observations, WebCAT.Feedback.Observation)

    timestamps()
  end

  @doc """
  Create a changeset for a category
  """
  def changeset(category, attrs \\ %{}) do
    category
    |> cast(attrs, ~w(name description parent_category_id)a)
    |> validate_required(~w(name)a)
    |> foreign_key_constraint(:parent_category_id)
    |> unique_constraint(:name)
  end

  def title_for(category) do
    category.name
  end
end
