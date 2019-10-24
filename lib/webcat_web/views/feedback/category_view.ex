defmodule WebCATWeb.CategoryView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "category", collection: "categories"

  def fields, do: ~w(name description inserted_at updated_at)a ++ ~w(parent_category_id)a

  def relationships,
    do: [
      classrooms: WebCATWeb.ClassroomView,
      parent_category: __MODULE__,
      sub_categories: __MODULE__,
      observations: WebCATWeb.ObservationView
    ]

  def inserted_at(data, _), do: to_unix_millis(data.inserted_at)
  def updated_at(data, _), do: to_unix_millis(data.updated_at)
end
