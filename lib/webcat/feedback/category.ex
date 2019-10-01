defmodule WebCAT.Feedback.Category do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

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

      changeset
      |> Map.put(:data, Map.put(changeset.data, :classrooms, []))
      |> put_assoc(changeset, :classrooms, Repo.all(from(c in WebCAT.Rotations.Classroom, where: c.id in ^ids)))
  end

  defp put_classrooms(changeset, _), do: changeset

end
