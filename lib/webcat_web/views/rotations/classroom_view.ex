defmodule WebCATWeb.ClassroomView do
  alias WebCAT.Rotations.Classroom
  alias WebCATWeb.{SemesterView, CategoryView, UserView}

  use WebCATWeb, :view
  use JSONAPI.View, type: "classroom", collection: "classrooms"

  def fields, do: ~w(course_code name description inserted_at updated_at)a

  def relationships, do: [semesters: SemesterView, categories: CategoryView, users: UserView]

  def inserted_at(data, _), do: Timex.to_unix(data.inserted_at)
  def updated_at(data, _), do: Timex.to_unix(data.updated_at)
end
