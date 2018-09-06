defmodule WebCATWeb.SemesterView do
  @moduledoc """
  Render semesters
  """

  use WebCATWeb, :view

  alias WebCAT.Rotations.Semester

  def render("list.json", %{semesters: semesters}) do
    render_many(semesters, __MODULE__, "semester.json")
  end

  def render("show.json", %{semester: semester}) do
    render_one(semester, __MODULE__, "semester.json")
  end

  def render("semester.json", %{semester: %Semester{} = semester}) do
    semester
    |> Map.from_struct()
    |> Map.take(~w(id start_date end_date title inserted_at updated_at)a)
  end
end
