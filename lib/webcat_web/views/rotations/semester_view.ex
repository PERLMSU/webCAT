defmodule WebCATWeb.SemesterView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "semester", collection: "semesters"

  def fields, do: ~w(name description start_date end_date inserted_at updated_at)a ++ ~w(classroom_id)a

  def relationships, do: [classroom: WebCATWeb.ClassroomView, sections: WebCATWeb.SectionView, users: WebCATWeb.UserView]

  def start_date(data, _), do: Timex.to_unix(data.start_date)
  def end_date(data, _), do: Timex.to_unix(data.end_date)
  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
