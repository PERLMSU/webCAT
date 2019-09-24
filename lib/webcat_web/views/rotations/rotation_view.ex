defmodule WebCATWeb.RotationView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "rotation", collection: "rotations"

  def fields, do: ~w(number description start_date end_date inserted_at updated_at)a ++ ~w(section_id)a

  def relationships, do: [section: WebCATWeb.SectionView, rotation_groups: WebCATWeb.RotationGroupView]

  def start_date(data, _), do: Timex.to_unix(data.start_date)
  def end_date(data, _), do: Timex.to_unix(data.end_date)
  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
