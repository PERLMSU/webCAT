defmodule WebCATWeb.ClassroomView do
  @moduledoc """
  Render classrooms
  """

  use WebCATWeb, :view

  alias WebCAT.Rotations.Classroom

  def render("list.json", %{classrooms: classrooms}) do
    render_many(classrooms, __MODULE__, "classroom.json")
  end

  def render("show.json", %{classroom: classroom}) do
    render_one(classroom, __MODULE__, "classroom.json")
  end

  def render("classroom.json", %{classroom: %Classroom{} = classroom}) do
    classroom
    |> Map.from_struct()
    |> Map.take(~w(id course_code section description semester_id inserted_at updated_at)a)
  end
end
