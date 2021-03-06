defmodule WebCATWeb.StudentFeedbackController do
  @moduledoc """
  Logic for working with the feedback writer
  """

  use WebCATWeb, :authenticated_controller

  alias WebCAT.Rotations.{Classroom, RotationGroup, Section}
  alias WebCAT.Feedback.{Category, StudentFeedback}
  alias WebCAT.Repo
  import Ecto.Query

  alias Terminator

  action_fallback(WebCATWeb.FallbackController)

  def classrooms(conn, user, _params) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      classrooms =
        if Terminator.has_role?(user.performer, :admin) do
          Classroom
          |> join(:left, [c], s in assoc(c, :semesters))
          |> preload([_, s], semesters: s)
          |> Repo.all()
        else
          Classroom
          |> join(:left, [c], u in assoc(c, :users))
          |> join(:left, [c], s in assoc(c, :semesters))
          # |> where([_, u], ^user.id in u.id)
          |> preload([_, _, s], semesters: s)
          |> Repo.all()
        end

      render(conn, "classrooms.html", user: user, selected: "feedback", classrooms: classrooms)
    end
  end

  def sections(conn, user, %{"semester_id" => semester_id}) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      sections =
        if Terminator.has_role?(user.performer, :admin) do
          Section
          |> where([s], s.semester_id == ^semester_id)
          |> join(:left, [s], r in assoc(s, :rotations))
          |> preload([_, r], rotations: r)
          |> Repo.all()
        else
          Section
          |> join(:left, [s], u in assoc(s, :users))
          |> join(:left, [s], r in assoc(s, :rotations))
          |> where([s], s.semester_id == ^semester_id)
          # |> where([_, u], ^user.id in u.id)
          |> preload([_, _, r], rotations: r)
          |> Repo.all()
        end

      render(conn, "sections.html", user: user, selected: "feedback", sections: sections)
    end
  end

  def groups(conn, user, %{"rotation_id" => rotation_id}) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      groups =
        if Terminator.has_role?(user.performer, :admin) do
          RotationGroup
          |> where([g], g.rotation_id == ^rotation_id)
          |> join(:left, [g], u in assoc(g, :users))
          |> join(:left, [_, u], p in assoc(u, :performer))
          |> join(:left, [_, _, p], r in assoc(p, :roles))
          |> preload([_, u, p, r], users: {u, performer: {p, roles: r}})
          |> Repo.all()
        else
          RotationGroup
          |> where([g], g.rotation_id == ^rotation_id)
          |> join(:left, [g], u in assoc(g, :users))
          |> join(:left, [_, u], p in assoc(u, :performer))
          |> join(:left, [_, _, p], r in assoc(p, :roles))
          # |> where([_, u], ^user.id in u.id)
          |> preload([_, u, p, r], users: {u, performer: {p, roles: r}})
          |> Repo.all()
        end

      render(conn, "groups.html", user: user, selected: "feedback", groups: groups)
    end
  end

  def students(conn, user, %{"group_id" => group_id}) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      group =
        if Terminator.has_role?(user.performer, :admin) do
          RotationGroup
          |> where([g], g.id == ^group_id)
          |> join(:left, [g], u in assoc(g, :users))
          |> join(:left, [_, u], p in assoc(u, :performer))
          |> join(:left, [_, _, p], r in assoc(p, :roles))
          |> preload([_, u, p, r], users: {u, performer: {p, roles: r}})
          |> Repo.one()
        else
          RotationGroup
          |> where([g], g.id == ^group_id)
          |> join(:left, [g], u in assoc(g, :users))
          |> join(:left, [_, u], p in assoc(u, :performer))
          |> join(:left, [_, _, p], r in assoc(p, :roles))
          |> preload([_, u, p, r], users: {u, performer: {p, roles: r}})
          |> Repo.one()
        end

      if group do
        render(conn, "students.html", user: user, selected: "feedback", group: group)
      else
        {:error, :not_found}
      end
    end
  end

  def categories(conn, user, params) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      parent_category_id = Map.get(params, "category_id")

      categories =
        if parent_category_id do
          Category
          |> where([c], c.parent_category_id == ^parent_category_id)
          |> join(:left, [c], o in assoc(c, :observations))
          |> join(:left, [_, o], f in assoc(o, :feedback))
          |> join(:left, [c], s in assoc(c, :sub_categories))
          |> preload([_, o, f, s], sub_categories: s, observations: {o, feedback: f})
          |> Repo.all()
        else
          Category
          |> join(:left, [c], o in assoc(c, :observations))
          |> join(:left, [_, o], f in assoc(o, :feedback))
          |> join(:left, [c], s in assoc(c, :sub_categories))
          |> preload([_, o, f, s], sub_categories: s, observations: {o, feedback: f})
          |> Repo.all()
        end

      selected_feedback =
        StudentFeedback
        |> where([sf], sf.user_id == ^params["user_id"])
        |> where([sf], sf.rotation_group_id == ^params["group_id"])
        |> select([sf], sf.feedback_id)
        |> Repo.all()

      render(conn, "categories.html",
        user: user,
        selected: "feedback",
        categories: categories,
        params: params,
        selected_feedback: selected_feedback
      )
    end
  end

  def feedback(conn, _user, %{
        "student_feedback" => feedback,
        "group_id" => group_id,
        "user_id" => user_id
      }) do
    feedback
    |> Enum.filter(fn {_, value} -> value == "true" end)
    |> Enum.map(fn {key, _} ->
      StudentFeedback.add(group_id, user_id, key)
    end)

    removed =
      feedback
      |> Enum.filter(fn {_, value} -> value == "false" end)
      |> Enum.map(fn {key, _} -> key end)

    # Remove deleted feedback
    StudentFeedback
    |> where([sf], sf.rotation_group_id == ^group_id)
    |> where([sf], sf.user_id == ^user_id)
    |> where([sf], sf.feedback_id in ^removed)
    |> Repo.delete_all()

    conn
    |> put_flash(:info, "Added feedback successfully!")
    |> redirect(to: Routes.student_feedback_path(conn, :students, group_id))
  end
end
