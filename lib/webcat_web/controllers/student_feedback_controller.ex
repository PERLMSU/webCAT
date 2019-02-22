defmodule WebCATWeb.StudentFeedbackController do
  @moduledoc """
  Logic for working with the feedback writer
  """

  use WebCATWeb, :authenticated_controller

  alias WebCAT.Accounts.Users
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{RotationGroup, Section}
  alias WebCAT.Feedback.{Observation, Category, Explanation}
  alias WebCAT.Repo
  import Ecto.Query

  alias Terminator

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, _params) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      sections =
        cond do
          Terminator.has_role?(user.performer, :admin) ->
            Section
            |> join(:left, [s], r in assoc(s, :rotations))
            |> join(:left, [s], u in assoc(s, :users))
            |> join(:left, [s], sem in assoc(s, :semester))
            |> join(:left, [_, _, _, s], c in assoc(s, :classroom))
            |> order_by([_, r], desc: r.end_date)
            |> preload([_, r, users, semester, classroom],
              rotations: r,
              users: users,
              semester: {semester, classroom: classroom}
            )
            |> Repo.all()

          true ->
            Section
            |> join(:left, [sections], r in assoc(sections, :rotations))
            |> Repo.all()
        end

      render(conn, "index.html", user: user, selected: "feedback", sections: sections)
    end
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
      |> preload(students: [:user])
      |> Repo.one()

    render(conn, "students.html", user: user, selected: "feedback", group: group)
  end

  def categories(conn, %{"group_id" => group_id, "student_id" => student_id} = params) do
  end
end
