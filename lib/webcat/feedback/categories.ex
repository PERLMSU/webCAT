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
    |> preload([_, s, s_s, c], sub_categories: {s, sub_categories: s_s}, classroom: c)
    |> Repo.one()
    |> case do
      nil ->
        {:error, :not_found}

      category ->
        {:ok, category}
    end
  end
end
