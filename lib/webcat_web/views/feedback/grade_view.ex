defmodule WebCATWeb.GradeView do
  use WebCATWeb, :view

  alias WebCAT.Feedback.{Category, Grade, Draft}
  alias WebCATWeb.{CategoryView, DraftView}

  def render("list.json", %{grades: grades}) do
    render_many(grades, __MODULE__, "grade.json")
  end

  def render("show.json", %{grade: grade}) do
    render_one(grade, __MODULE__, "grade.json")
  end

  def render("grade.json", %{grade: %Grade{} = grade}) do
    grade
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{draft: %Draft{} = draft} = map ->
        Map.put(map, :draft, render_one(draft, DraftView, "draft.json"))

      map ->
        Map.delete(map, :draft)
    end
    |> case do
      %{category: %Category{} = category} = map ->
        Map.put(map, :category, render_one(category, CategoryView, "category.json"))

      map ->
        Map.delete(map, :category)
    end
  end
end
