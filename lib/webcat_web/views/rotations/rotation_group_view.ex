defmodule WebCATWeb.RotationGroupView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "rotation", collection: "rotations"

  def fields, do: ~w(number description inserted_at updated_at)a ++ ~w(rotation_id)a

  def relationships, do: [rotation: WebCATWeb.RotationView, users: WebCATWeb.UserView]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
