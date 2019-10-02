defmodule WebCATWeb.SectionView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "section", collection: "sections"

  def fields, do: ~w(number description inserted_at updated_at)a ++ ~w(semester_id classroom_id)a

  def relationships, do: [semester: WebCATWeb.SemesterView, rotations: WebCATWeb.RotationView, users: WebCATWeb.UserView, classroom: WebCATWeb.ClassroomView]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
