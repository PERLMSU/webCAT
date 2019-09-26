defmodule WebCATWeb.GradeView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "grade", collection: "grades"

  alias WebCATWeb.{CategoryView, DraftView}

  def fields, do: ~w(score note inserted_at updated_at)a ++ ~w(draft_id category_id)a

  def relationships, do: [draft: DraftView, category: CategoryView]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
