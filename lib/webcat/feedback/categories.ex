defmodule WebCAT.Feedback.Categories do
  import Ecto.Query
  alias WebCAT.Feedback.Category
  alias WebCAT.Repo

  def list(classroom_id) when is_binary(classroom_id) or is_integer(classroom_id) do
    Category
    |> where([c], c.classroom_id == ^classroom_id)
    |> where([c], is_nil(c.parent_category_id))
    |> join(:left, [c], s in assoc(c, :sub_categories))
    |> preload([_, s], sub_categories: s)
    |> Repo.all()
  end

  def get(id) when is_binary(id) or is_integer(id) do
    Category
    |> where([c], c.id == ^id)
    |> join(:left, [c], s in assoc(c, :sub_categories))
    |> join(:left, [_, s], s_s in assoc(s, :sub_categories))
    |> join(:left, [c], cl in assoc(c, :classroom))
    |> join(:left, [c], obs in assoc(c, :observations))
    |> join(:left, [_, _, _,_, o], p_cat in assoc(o, :category))
    |> preload([_, s, s_s, c, o, p_cat], sub_categories: {s, sub_categories: s_s}, classroom: c, observations: {o, category: p_cat})
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      category ->
        {:ok, category}
    end
  end
end
