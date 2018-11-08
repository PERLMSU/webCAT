defmodule WebCAT.Feedback.Category do
  @behaviour WebCAT.Dashboardable
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.User

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

  def title_for(category), do: category.name

  def table_fields(), do: ~w(name description)a

  def display(category) do
    category
    |> Map.from_struct()
    |> Map.take(~w(id name description)a)
  end

  # Policy behavior

  def authorize(action, %User{}, _)
      when action in ~w(list_categories show_category)a,
      do: true

  def authorize(action, %User{role: "admin"}, _)
      when action in ~w(create_category update_category delete_category)a,
      do: true

  def authorize(_, _, _), do: false
end
