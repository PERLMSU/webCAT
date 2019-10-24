defmodule WebCATWeb.SemesterView do
  use WebCATWeb, :view
  use JSONAPI.View, type: "semester", collection: "semesters"

  def fields, do: ~w(name description start_date end_date inserted_at updated_at)a

  def relationships, do: [sections: WebCATWeb.SectionView, users: WebCATWeb.UserView]

  def start_date(data, _), do: to_unix_millis(data.start_date)
  def end_date(data, _), do: to_unix_millis(data.end_date)
  def inserted_at(data, _), do: to_unix_millis(data.inserted_at)
  def updated_at(data, _), do: to_unix_millis(data.updated_at)
end
