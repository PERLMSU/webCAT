defmodule WebCATWeb.SectionView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.{Section, Semester}

  def render("list.json", %{sections: sections}) do
    render_many(sections, __MODULE__, "section.json")
  end

  def render("show.json", %{section: section}) do
    render_one(section, __MODULE__, "section.json")
  end

  def render("section.json", %{section: %Section{} = section}) do
    section
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{semester: %Semester{} = semester} = map ->
        Map.put(
          map,
          :semester,
          render_one(semester, WebCATWeb.SemesterView, "semester.json")
        )

      map ->
        Map.delete(map, :rotation)
    end
    |> case do
      %{rotations: rotations} = map when is_list(rotations) ->
        Map.put(
          map,
          :rotations,
          render_many(rotations, WebCATWeb.RotationView, "rotation.json")
        )

      map ->
        Map.delete(map, :rotations)
    end
    |> case do
      %{users: users} = map when is_list(users) ->
        Map.put(map, :users, render_many(users, WebCATWeb.UserView, "user.json"))

      map ->
        Map.delete(map, :users)
    end
  end
end
