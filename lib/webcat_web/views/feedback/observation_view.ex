defmodule WebCATWeb.ObservationView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "observation", collection: "observations"

  alias WebCATWeb.{CategoryView, FeedbackView}

  def fields, do: ~w(content type inserted_at updated_at)a ++ ~w(category_id)a

  def relationships, do: [category: CategoryView, feedback: FeedbackView]

  def inserted_at(data, _), do: to_unix_millis(data.inserted_at)
  def updated_at(data, _), do: to_unix_millis(data.updated_at)
end
