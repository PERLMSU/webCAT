defmodule WebCATWeb.RotationGroupView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "rotation_group", collection: "rotation_groups"

  def fields, do: ~w(number description inserted_at updated_at)a ++ ~w(rotation_id)a

  def relationships, do: [rotation: WebCATWeb.RotationView, users: WebCATWeb.UserView, classroom: WebCATWeb.ClassroomView]

  def inserted_at(data, _), do: to_unix_millis(data.inserted_at)
  def updated_at(data, _), do: to_unix_millis(data.updated_at)
end
