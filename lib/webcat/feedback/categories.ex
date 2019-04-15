defmodule WebCAT.Feedback.Categories do
  import Ecto.Query
  alias WebCAT.Feedback.Category
  alias WebCAT.Repo

  def list() do
    from(category in Category,
      left_join: sub_categories in assoc(category, :sub_categories),
      left_join: parent_category in assoc(category, :parent_category),
      preload: [sub_categories: sub_categories, parent_category: parent_category]
    )
    |> Repo.all()
  end

  def list(classroom_id) do
    from(category in Category,
      where: category.classroom_id == ^classroom_id,
      left_join: sub_categories in assoc(category, :sub_categories),
      left_join: parent_category in assoc(category, :parent_category),
      preload: [sub_categories: sub_categories, parent_category: parent_category]
    )
    |> Repo.all()
  end

  def get(id) when is_binary(id) or is_integer(id) do
    from(category in Category,
      where: category.id == ^id,
      left_join: parent_category in assoc(category, :parent_category),
      left_join: sub_categories in assoc(category, :sub_categories),
      left_join: sub_parents in assoc(sub_categories, :parent_category),
      left_join: sub_sub_categories in assoc(sub_categories, :sub_categories),
      left_join: classroom in assoc(category, :classroom),
      left_join: class_categories in assoc(classroom, :categories),
      left_join: observations in assoc(category, :observations),
      left_join: observation_category in assoc(observations, :category),
      preload: [
        parent_category: parent_category,
        sub_categories:
          {sub_categories, sub_categories: sub_sub_categories, parent_category: sub_parents},
        classroom: {classroom, categories: class_categories},
        observations: {observations, category: observation_category}
      ]
    )
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      category ->
        {:ok, category}
    end
  end
end
