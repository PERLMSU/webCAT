defmodule WebCATWeb.EmailView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "email", collection: "emails"

  def fields,
    do: ~w(status inserted_at updated_at)a ++ ~w(draft_id)a

  def relationships, do: [draft: WebCATWeb.DraftView]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
