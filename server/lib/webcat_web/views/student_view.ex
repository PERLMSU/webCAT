defmodule WebCATWeb.StudentView do
  @moduledoc """
  Render students
  """

  use WebCATWeb, :view

  alias WebCAT.Rotations.Student

  def render("list.json", %{students: students}) do
    render_many(students, __MODULE__, "student.json")
  end

  def render("show.json", %{student: student}) do
    render_one(student, __MODULE__, "student.json")
  end

  def render("student.json", %{student: %Student{} = student}) do
    student
    |> Map.from_struct()
    |> Map.take(~w(id first_name last_name middle_name description email classroom_id inserted_at updated_at)a)
  end
end
