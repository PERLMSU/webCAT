defmodule WebCATWeb.CategoryView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "category", collection: "categories"

  def fields, do: ~w(name description inserted updated)a

  def relationships,
    do: [
      classroom: WebCATWeb.ClassroomView,
      parent_category: __MODULE__,
      sub_categories: __MODULE__,
      observations: WebCATWeb.ObservationView
    ]

  def inserted(semester, _), do: Timex.to_unix(semester.inserted_at)
  def updated(semester, _), do: Timex.to_unix(semester.updated_at)
end
