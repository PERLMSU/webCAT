defmodule WebCATWeb.UserView do
  use WebCATWeb, :view

  alias WebCAT.Accounts.User

  alias WebCATWeb.{
    ClassroomView,
    SemesterView,
    SectionView,
    RotationView,
    RotationGroupView,
    RoleView
  }

  def render("list.json", %{users: users}) do
    render_many(users, __MODULE__, "user.json")
  end

  def render("show.json", %{user: user}) do
    render_one(user, __MODULE__, "user.json")
  end

  def render("user.json", %{user: %User{} = user}) do
    user
    |> Map.from_struct()
    |> Map.drop(~w(__meta__ performer_id performer notifications)a)
    |> timestamps_format()
    |> case do
      %{classrooms: classrooms} = map when is_list(classrooms) ->
        Map.put(
          map,
          :classrooms,
          render_many(classrooms, ClassroomView, "classroom.json")
        )

      map ->
        Map.delete(map, :classrooms)
    end
    |> case do
      %{semesters: semesters} = map when is_list(semesters) ->
        Map.put(
          map,
          :semesters,
          render_many(semesters, SemesterView, "semester.json")
        )

      map ->
        Map.delete(map, :semesters)
    end
    |> case do
      %{sections: sections} = map when is_list(sections) ->
        Map.put(
          map,
          :sections,
          render_many(sections, SectionView, "section.json")
        )

      map ->
        Map.delete(map, :sections)
    end
    |> case do
      %{rotations: rotations} = map when is_list(rotations) ->
        Map.put(
          map,
          :rotations,
          render_many(rotations, RotationView, "rotation.json")
        )

      map ->
        Map.delete(map, :rotations)
    end
    |> case do
      %{rotation_groups: rotation_groups} = map when is_list(rotation_groups) ->
        Map.put(
          map,
          :rotation_groups,
          render_many(rotation_groups, RotationGroupView, "group.json")
        )

      map ->
        Map.delete(map, :rotation_groups)
    end
    |> case do
      %{roles: roles} = map when is_list(roles) ->
        Map.put(
          map,
          :roles,
          render_many(roles, RoleView, "role.json")
        )

      map ->
        Map.delete(map, :roles)
    end
  end
end
