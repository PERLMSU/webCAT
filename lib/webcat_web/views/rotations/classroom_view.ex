defmodule WebCATWeb.ClassroomView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.Classroom
  alias WebCATWeb.{SemesterView, CategoryView, UserView}

  def render("list.json", %{classrooms: classrooms}) do
    render_many(classrooms, __MODULE__, "classroom.json")
  end

  def render("show.json", %{classroom: classroom}) do
    render_one(classroom, __MODULE__, "classroom.json")
  end

  def render("classroom.json", %{classroom: %Classroom{} = classroom}) do
    classroom
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{semesters: semesters} = map when is_list(semesters) ->
        Map.put(map, :semesters, render_many(semesters, SemesterView, "semester.json"))

      map ->
        Map.delete(map, :semesters)
    end
    |> case do
      %{categories: categories} = map when is_list(categories) ->
        Map.put(map, :categories, render_many(categories, CategoryView, "category.json"))

      map ->
        Map.delete(map, :categories)
    end
    |> case do
      %{users: users} = map when is_list(users) ->
        Map.put(map, :users, render_many(users, UserView, "user.json"))

      map ->
        Map.delete(map, :users)
    end
  end
end
