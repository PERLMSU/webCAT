defmodule WebCATWeb.CategoriesView do
  use WebCATWeb, :view

  def clean_category(category) do
    category
    |> Map.from_struct()
    |> Map.take(~w(id name description)a)
  end
end
