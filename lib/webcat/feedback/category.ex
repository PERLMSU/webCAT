defmodule WebCAT.Feedback.Category do
  @behaviour Bodyguard.Policy

  use Ecto.Schema
  import Ecto.Changeset
  alias WebCAT.Accounts.{User, Groups}

  schema "categories" do
    field(:name, :string)
    field(:description, :string)

    belongs_to(:parent_category, WebCAT.Feedback.Category)
    belongs_to(:classroom, WebCAT.Rotations.Classroom)
    has_many(:sub_categories, WebCAT.Feedback.Category, foreign_key: :parent_category_id)
    has_many(:observations, WebCAT.Feedback.Observation, foreign_key: :category_id)

    timestamps()
  end

  @required ~w(name classroom_id)a
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
  end

  # Policy behaviour

  def authorize(action, %User{}, _)
      when action in ~w(list show)a,
      do: true

  def authorize(action, %User{groups: groups}, _)
      when action in ~w(create update delete)a and is_list(groups),
      do: Groups.has_group?(groups, "admin")

  def authorize(_, _, _), do: false
end
