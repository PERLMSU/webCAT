defmodule WebCATWeb.NotificationView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "notification", collection: "notifications"

  def fields, do: ~w(content seen inserted_at updated_at)a ++ ~w(user_id draft_id)a

  def relationships, do: [user: WebCATWeb.UserView, draft: WebCATWeb.DraftView]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
