defmodule WebCATWeb.ClassroomView do
  use JSONAPI.View

  alias WebCATWeb.{SemesterView, CategoryView, UserView}

  def fields, do: ~w(id course_code name description)a

  def type, do: "classroom"

  def relationships do
    [ semesters: SemesterView,
      categories: CategoryView,
      users: UserView ]
  end
end
