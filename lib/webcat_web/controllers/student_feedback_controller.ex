defmodule WebCATWeb.StudentFeedbackController do
  @moduledoc """
  Logic for working with the feedback writer
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.{Users, Groups}
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Classroom, RotationGroup, Section, Rotation}
  alias WebCAT.Feedback.{Observation, Category, Explanation}
  alias WebCAT.Repo
  import Ecto.Query

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    sections =
      cond do
        Groups.has_group?(user.groups, "admin") ->
          Section
          |> join(:left, [s], r in assoc(s, :rotations))
          |> join(:left, [s], stu in assoc(s, :students))
          |> join(:left, [s], sem in assoc(s, :semester))
          |> join(:left, [_, _, _, s], c in assoc(s, :classroom))
          |> order_by([_, r], desc: r.end_date)
          |> preload([_, r, students, semester, classroom],
            rotations: r,
            students: students,
            semester: {semester, classroom: classroom}
          )
          |> Repo.all()

        true ->
          Section
          |> join(:left, [sections], r in assoc(sections, :rotations))
          |> join(:left, [_, rotations], rotation_groups in assoc(rotations, :rotation_groups))
          |> join(:left, [_, _, rotation_groups], users in assoc(rotation_groups, :users))
          |> join(:left, [sections], students in assoc(sections, :students))
          |> join(:left, [sections], semesters in assoc(sections, :semester))
          |> join(:left, [_, _, _, _, _, semesters], classrooms in assoc(semesters, :classroom))
          |> where([_, _, _, users], users.id == ^user.id)
          |> order_by([_, rotations], desc: rotations.end_date)
          |> preload([_, rotations, _, _, students, semesters, classrooms],
            rotations: rotations,
            students: students,
            semester: {semesters, classroom: classrooms}
          )
          |> Repo.all()
      end

    render(conn, "index.html", user: user, selected: "feedback", sections: sections)
  end

  def groups(conn, %{"rotation_id" => rotation_id}) do
    user = Auth.current_resource(conn)

    groups =
      cond do
        Groups.has_group?(user.groups, "admin") ->
          RotationGroup
          |> where([g], g.rotation_id == ^rotation_id)
          |> join(:left, [g], s in assoc(g, :students))
          |> join(:left, [_, s], u in assoc(s, :user))
          |> preload([_, s, u], students: {s, user: u})
          |> Repo.all()

        true ->
          RotationGroup
          |> join(:left, [g], u in assoc(g, :users))
          |> join(:left, [g], s in assoc(g, :students))
          |> join(:left, [_, s], u in assoc(s, :user))
          |> where([g], g.rotation_id == ^rotation_id)
          |> where([_, u], u.id == ^user.id)
          |> preload([_, _, s, u], students: {s, user: u})
          |> Repo.all()
      end

    render(conn, "groups.html", user: user, selected: "feedback", groups: groups)
  end

  def students(conn, %{"group_id" => group_id}) do
    user = Auth.current_resource(conn)

    group =
      RotationGroup
      |> where([g], g.id == ^group_id)
      |> preload([students: [:user]])
      |> Repo.one()

    render(conn, "students.html", user: user, selected: "feedback", group: group)
  end

  def categories(conn, %{"group_id" => group_id, "student_id" => student_id} = params) do

  end
end
