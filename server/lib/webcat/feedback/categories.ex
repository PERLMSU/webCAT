defmodule WebCAT.Feedback.Categories do
  @moduledoc """
  Helper functions for working with categories
  """

  alias WebCAT.Repo
  alias WebCAT.Feedback.{Category, Observation}

  import Ecto.Query

  @spec list(Keyword.t()) :: {:ok, [Category.t()]}
  def list(options \\ []) do
    Category
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> Repo.all()
  end

  @spec get(integer) :: {:error, :not_found} | {:ok, Category.t()}
  def get(id) do
    case Repo.get(Category, id) do
      %Category{} = category -> {:ok, category}
      nil -> {:error, :not_found}
    end
  end

  def create(params) do
    %Category{}
    |> Category.changeset(params)
    |> Repo.insert()
  end

  def update(id, update) do
    with {:ok, category} <- get(id) do
      category
      |> Category.changeset(update)
      |> Repo.update()
    end
  end

  def delete(id) do
    with {:ok, category} <- get(id) do
      Repo.delete(category)
    end
  end

  def observations(category_id, options \\ []) do
    Observation
    |> where([o], o.category_id == ^category_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
