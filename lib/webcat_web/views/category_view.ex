defmodule WebCATWeb.CategoryView do
  @moduledoc """
  Render categories
  """

  use WebCATWeb, :view

  alias WebCAT.Feedback.Category

  def render("list.json", %{categories: categories}) do
    render_many(categories, __MODULE__, "category.json")
  end

  def render("show.json", %{category: category}) do
    render_one(category, __MODULE__, "category.json")
  end

  def render("category.json", %{category: %Category{} = category}) do
    category
    |> Map.from_struct()
    |> Map.take(~w(id name description parent_category_id inserted_at updated_at)a)
  end
end
