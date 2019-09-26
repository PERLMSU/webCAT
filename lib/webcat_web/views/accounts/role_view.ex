defmodule WebCATWeb.RoleView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "role", collection: "roles"

  def fields, do: ~w(identifier name inserted_at updated_at)a

  def relationships, do: []

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
