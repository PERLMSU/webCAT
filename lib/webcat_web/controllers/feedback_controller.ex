defmodule WebCATWeb.FeedbackController do
  @moduledoc """
  Logic for working with the feedback writer
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Classroom, RotationGroup, Section, Rotation}
  alias WebCAT.Feedback.{Observation, Category, Explanation}
  alias WebCAT.Repo
  import Ecto.Query

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    sections =
      case user.role do
        "assistant" ->
          Section
          |> join(:left, [s], r in assoc(s, :rotations))
          |> join(:left, [s], u in assoc(s, :users))
          |> join(:left, [s], students in assoc(s, :students))
          |> join(:left, [s], sem in assoc(s, :semester))
          |> join(:left, [_, _, _, _, s], c in assoc(s, :classroom))
          |> where([_, _, u], u.id == ^user.id)
          |> order_by([_, r], desc: r.end_date)
          |> preload([_, r, _, s, semester, classroom],
            rotations: r,
            students: s,
            semester: {semester, classroom: classroom}
          )
          |> Repo.all()

        "admin" ->
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
      end

    render(conn, "index.html", user: user, selected: "feedback", sections: sections)
  end

  def groups(conn, %{"rotation_id" => rotation_id}) do
    user = Auth.current_resource(conn)

    groups =
      case user.role do
        "assistant" ->
          RotationGroup
          |> join(:left, [g], u in assoc(g, :users))
          |> join(:left, [g], s in assoc(g, :students))
          |> where([g], g.rotation_id == ^rotation_id)
          |> where([_, u], u.id == ^user.id)
          |> preload([_, _, s], students: s)
          |> Repo.all()

        "admin" ->
          RotationGroup
          |> where([g], g.rotation_id == ^rotation_id)
          |> join(:left, [g], s in assoc(g, :students))
          |> preload([_, s], students: s)
          |> Repo.all()
      end

    render(conn, "groups.html", user: user, selected: "feedback", groups: groups)
  end

  def observations(conn, %{"group_id" => group_id}) do
    user = Auth.current_resource(conn)

    group =
      RotationGroup
      |> where([g], g.id == ^group_id)
      |> preload([:students, observations: [:explanations, :category]])
      |> Repo.one()

    render(conn, "observations.html", user: user, selected: "feedback", group: group)
  end

  def new_observation(conn, %{"group_id" => group_id}) do
    user = Auth.current_resource(conn)
    changeset = Observation.changeset(%Observation{rotation_group_id: group_id})
    categories = CRUD.list(Category)

    render(conn, "new_observation.html",
      user: user,
      selected: "feedback",
      changeset: changeset,
      categories: categories
    )
  end

  def create_observation(conn, %{"observation" => observation}) do
    user = Auth.current_resource(conn)

    case CRUD.create(Observation, observation) do
      {:ok, observation} ->
        redirect(conn,
          to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
        )

      {:error, changeset} ->
        categories = CRUD.list(Category)

        render(conn, "new_observation.html",
          user: user,
          selected: "feedback",
          changeset: changeset,
          categories: categories
        )
    end
  end

  def edit_observation(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, observation} <- CRUD.get(Observation, id),
         :ok <- Bodyguard.permit(Observation, :update, user, observation) do
      categories = CRUD.list(Category)

      render(conn, "edit_observation.html",
        user: user,
        selected: "feedback",
        changeset: Observation.changeset(observation),
        categories: categories
      )
    end
  end

  def update_observation(conn, %{"id" => id, "observation" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, observation} <- CRUD.get(Observation, id),
         :ok <- Bodyguard.permit(Observation, :update, user, observation) do
      case CRUD.update(Observation, observation, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Observation updated!")
          |> redirect(
            to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
          )

        {:error, %Ecto.Changeset{} = changeset} ->
          categories = CRUD.list(Category)

          render(conn, "edit.html",
            user: user,
            selected: "feedback",
            changeset: changeset,
            categories: categories
          )
      end
    end
  end

  def delete_observation(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, observation} <- CRUD.get(Observation, id),
         :ok <- Bodyguard.permit(Observation, :delete, user, observation) do
      case CRUD.delete(Observation, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Observation deleted successfully")
          |> redirect(
            to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
          )

        {:error, _} ->
          conn
          |> put_flash(:error, "Observation deletion failed")
          |> redirect(
            to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
          )
      end
    end
  end

  def new_explanation(conn, %{"observation_id" => observation_id}) do
    user = Auth.current_resource(conn)
    changeset = Explanation.changeset(%Explanation{observation_id: observation_id})

    render(conn, "new_explanation.html",
      user: user,
      selected: "feedback",
      changeset: changeset
    )
  end

  def create_explanation(conn, %{"explanation" => explanation}) do
    user = Auth.current_resource(conn)

    case CRUD.create(Explanation, explanation) do
      {:ok, explanation} ->
        {:ok, observation} = CRUD.get(Observation, explanation.observation_id)

        redirect(conn,
          to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
        )

      {:error, changeset} ->
        render(conn, "new_explanation.html",
          user: user,
          selected: "feedback",
          changeset: changeset
        )
    end
  end

  def edit_explanation(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, explanation} <- CRUD.get(Explanation, id),
         :ok <- Bodyguard.permit(Explanation, :update, user, explanation) do
      render(conn, "edit_explanation.html",
        user: user,
        selected: "feedback",
        changeset: Explanation.changeset(explanation)
      )
    end
  end

  def update_explanation(conn, %{"id" => id, "explanation" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, explanation} <- CRUD.get(Explanation, id),
         :ok <- Bodyguard.permit(Explanation, :update, user, explanation) do
      case CRUD.update(Explanation, explanation, update) do
        {:ok, _} ->
          {:ok, observation} = CRUD.get(Observation, explanation.observation_id)

          conn
          |> put_flash(:info, "Explanation updated!")
          |> redirect(
            to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
          )

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "feedback",
            changeset: changeset
          )
      end
    end
  end

  def delete_explanation(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, explanation} <- CRUD.get(Explanation, id),
         :ok <- Bodyguard.permit(Explanation, :delete, user, explanation),
         {:ok, observation} <- CRUD.get(Observation, explanation.observation_id) do
      case CRUD.delete(Explanation, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Explanation deleted successfully")
          |> redirect(
            to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
          )

        {:error, _} ->
          conn
          |> put_flash(:error, "Explanation deletion failed")
          |> redirect(
            to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
          )
      end
    end
  end
end
