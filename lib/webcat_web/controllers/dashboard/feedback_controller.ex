defmodule WebCATWeb.FeedbackController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Feedback.Feedback

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"observation_id" => observation_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         feedback <- Feedback.list(observation_id) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        feedback: feedback
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, feedback} <- Feedback.get(id) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        feedback: feedback
      )
    end
  end

  def new(conn, user, %{"observation_id" => observation_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      conn
      |> render("new.html",
        user: user,
        changeset: Feedback.changeset(%Feedback{observation_id: observation_id}),
        selected: "classroom"
      )
    end
  end

  def create(conn, user, %{"feedback" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(Feedback, params) do
        {:ok, feedback} ->
          conn
          |> put_flash(:info, "Feedback created!")
          |> redirect(to: Routes.feedback_path(conn, :show, feedback.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom"
          )
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, feedback} <- Feedback.get(id) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Feedback.changeset(feedback)
      )
    end
  end

  def update(conn, user, %{"id" => id, "feedback" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, feedback} <- Feedback.get(id) do
      case CRUD.update(Feedback, feedback, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Feedback updated!")
          |> redirect(to: Routes.feedback_path(conn, :show, id))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "classroom",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.delete(Feedback, id) do
        {:ok, feedback} ->
          conn
          |> put_flash(:info, "Feedback deleted successfully")
          |> redirect(
            to: Routes.feedback_path(conn, :index, observation_id: feedback.observation_id)
          )

        {:error, %Ecto.Changeset{}} ->
          conn
          |> put_flash(:error, "Feedback deletion failed")
          |> redirect(to: Routes.feedback_path(conn, :index))
      end
    end
  end
end
