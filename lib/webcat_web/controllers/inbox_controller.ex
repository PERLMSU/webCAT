defmodule WebCATWeb.InboxController do
  use WebCATWeb, :controller

  alias WebCAT.Repo
  import Ecto.Query

  alias WebCAT.Feedback.{Draft, Criteria, Grade, Observation}
  alias WebCAT.Rotations.{Student}
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Draft, :list, user) do
      drafts_query =
        Draft
        |> join(:left, [d], c in assoc(d, :comments))
        |> join(:left, [d], rg in assoc(d, :rotation_group))
        |> join(:left, [d], s in assoc(d, :student))
        |> join(:left, [_d, _c, rg, _s], u in assoc(rg, :users))
        |> join(:left, [_d, _c, rg, _s, _u], r in assoc(rg, :rotation))
        |> order_by([d], d.updated_at)
        |> preload([_, c, rg, s, u, r],
          comments: c,
          student: s,
          rotation_group: {rg, users: u, rotation: r}
        )

      drafts =
        case user.role do
          "assistant" ->
            drafts_query
            |> where([_, _, _, _, u], ^user.id in u.id)
            |> Repo.all()
            |> Enum.group_by(& &1.status)

          "admin" ->
            drafts_query
            |> Repo.all()
            |> Enum.group_by(& &1.status)
        end

      render(conn, "index.html", user: user, selected: "inbox", drafts: drafts)
    end
  end

  def new(conn, %{"group_id" => group_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Draft, :create, user) do
      students =
        Student
        |> join(:left, [s], rg in assoc(s, :rotation_groups))
        |> where([_, rg], rg.id == ^group_id)
        |> Repo.all()

      observations =
        Observation
        |> where([o], o.rotation_group_id == ^group_id)
        |> Repo.all()

      render(conn, "new.html",
        user: user,
        selected: "inbox",
        students: students,
        observations: observations,
        changeset: Draft.changeset(%Draft{rotation_group_id: group_id})
      )
    end
  end

  def create(conn, %{"draft" => draft}) do
    user = Auth.current_resource(conn)

    case CRUD.create(Draft, draft) do
      {:ok, draft} ->
        conn
        |> put_flash(:info, "Draft created!")
        |> redirect(to: Routes.feedback_path(conn, :observations, draft.rotation_group_id))

      {:error, changeset} ->
        students =
          Student
          |> join(:left, [s], rg in assoc(s, :rotation_groups))
          |> where([_, rg], rg.id == ^draft.rotation_group_id)
          |> Repo.all()

        observations =
          Observation
          |> where([o], o.rotation_group_id == ^draft.rotation_group_id)
          |> Repo.all()

        render(conn, "new.html",
          user: user,
          selected: "inbox",
          students: students,
          observations: observations,
          changeset: changeset
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, draft} <- CRUD.get(Draft, id),
         :ok <- Bodyguard.permit(Draft, :update, user, draft) do
      students =
        Student
        |> join(:left, [s], rg in assoc(s, :rotation_groups))
        |> where([_, rg], rg.id == ^draft.rotation_group_id)
        |> Repo.all()

      observations =
        Observation
        |> where([o], o.rotation_group_id == ^draft.rotation_group_id)
        |> Repo.all()

      render(conn, "edit.html",
        user: user,
        selected: "feedback",
        students: students,
        observations: observations,
        changeset: Draft.changeset(draft)
      )
    end
  end

  def update(conn, %{"id" => id, "draft" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, draft} <- CRUD.get(Draft, id),
         :ok <- Bodyguard.permit(Draft, :update, user, draft) do
      case CRUD.update(Draft, draft, update) do
        {:ok, _} ->
          {:ok, observation} = CRUD.get(Observation, draft.observation_id)

          conn
          |> put_flash(:info, "Draft updated!")
          |> redirect(
            to: Routes.feedback_path(conn, :observations, observation.rotation_group_id)
          )

        {:error, %Ecto.Changeset{} = changeset} ->
          students =
            Student
            |> join(:left, [s], rg in assoc(s, :rotation_groups))
            |> where([_, rg], rg.id == ^draft.rotation_group_id)
            |> Repo.all()

          observations =
            Observation
            |> where([o], o.rotation_group_id == ^draft.rotation_group_id)
            |> Repo.all()

          render(conn, "edit.html",
            user: user,
            selected: "feedback",
            students: students,
            observations: observations,
            changeset: changeset
          )
      end
    end
  end
end
