defmodule WebCATWeb.GradeView do
  @moduledoc """
  Render grades
  """

  use WebCATWeb, :view

  alias WebCAT.Feedback.Grade

  def render("list.json", %{grades: grades}) do
    render_many(grades, __MODULE__, "grade.json")
  end

  def render("show.json", %{grade: grade}) do
    render_one(grade, __MODULE__, "grade.json")
  end

  def render("grade.json", %{grade: %Grade{} = grade}) do
    grade
    |> Map.from_struct()
    |> Map.take(~w(id score draft_id inserted_at updated_at)a)
  end
end
