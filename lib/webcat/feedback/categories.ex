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

  def list(parent_category_id) do
    from(cat in Category,
      where: cat.parent_category_id== ^parent_category_id,
      left_join: sub_cat in assoc(cat, :sub_categories),
      left_join: obs in assoc(cat, :observations),
      left_join: feed in assoc(obs, :feedback),
      left_join: expl in assoc(feed, :explanations),
      order_by: [desc: cat.name],
      preload: [sub_categories: sub_cat, observations: {obs, feedback: {feed, explanations: expl}}]
    )
    |> Repo.all()
  end

  def get(id) when is_binary(id) or is_integer(id) do
    from(cat in Category,
      where: cat.id == ^id,
      left_join: sub_cat in assoc(cat, :sub_categories),
      left_join: obs in assoc(cat, :observations),
      left_join: feed in assoc(obs, :feedback),
      left_join: expl in assoc(feed, :explanations),
      preload: [sub_categories: sub_cat, observations: {obs, feedback: {feed, explanations: expl}}]
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
