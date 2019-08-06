defmodule WebCATWeb.SemesterView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.{Classroom, Semester}

  def render("list.json", %{semesters: semesters}) do
    render_many(semesters, __MODULE__, "semester.json")
  end

  def render("show.json", %{semester: semester}) do
    render_one(semester, __MODULE__, "semester.json")
  end

  def render("semester.json", %{semester: %Semester{} = semester}) do
    semester
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> Map.update!(:start_date, &Timex.to_unix/1)
    |> Map.update!(:end_date, &Timex.to_unix/1)
    |> timestamps_format()
    |> case do
      %{classroom: %Classroom{} = classroom} = map ->
        Map.put(
          map,
          :classroom,
          render_one(classroom, WebCATWeb.ClassroomView, "classroom.json")
        )

      map ->
        Map.delete(map, :classroom)
    end
    |> case do
      %{sections: sections} = map when is_list(sections) ->
        Map.put(
          map,
          :sections,
          render_many(sections, WebCATWeb.SectionView, "section.json")
        )

      map ->
        Map.delete(map, :sections)
    end
    |> case do
      %{users: users} = map when is_list(users) ->
        Map.put(map, :users, render_many(users, WebCATWeb.UserView, "user.json"))

      map ->
        Map.delete(map, :users)
    end
  end
end
