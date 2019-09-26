defmodule WebCATWeb.CommentView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "comments", collection: "comments"

  alias WebCATWeb.{DraftView, UserView}

  def fields, do: ~w(content inserted_at updated_at)a ++ ~w(draft_id user_id)a

  def relationships, do: [draft: DraftView, user: UserView]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
