defmodule WebCATWeb.FeedbackController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Feedback.{Observation, Feedback}

  @observation_preload [:feedback, category: ~w(classroom)a]
  @list_preload [observation: @observation_preload]
  @preload @list_preload

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"observation_id" => observation_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, observation} <- CRUD.get(Observation, observation_id, preload: @observation_preload),
         feedback <- CRUD.list(Feedback, preload: @list_preload, where: [observation_id: observation_id]) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        observation: observation,
        feedback: feedback
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, feedback} <- CRUD.get(Feedback, id, preload: @preload) do
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

    with :ok <- is_authorized?(),
         {:ok, observation} <- CRUD.get(Observation, observation_id, preload: @observation_preload) do
      conn
      |> render("new.html",
        user: user,
        changeset: Feedback.changeset(%Feedback{}, %{}),
        observation: observation,
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
          |> redirect(to: Routes.feedback_path(conn, :show, feedback.observation_id, feedback.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          {:ok, observation} = CRUD.get(Observation, params["observation_id"], preload: @observation_preload)

          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom",
            observation: observation
          )
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, feedback} <- CRUD.get(Feedback, id, preload: @preload) do

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
         {:ok, feedback} <- CRUD.get(Feedback, id, preload: @preload) do
      case CRUD.update(Feedback, feedback, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Feedback updated!")
          |> redirect(to: Routes.feedback_path(conn, :show, feedback.observation_id, id))

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

    with :ok <- is_authorized?(),
         {:ok, feedback} <- CRUD.get(Feedback, id) do
      case CRUD.delete(Feedback, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Feedback deleted successfully")
          |> redirect(to: Routes.feedback_path(conn, :index, feedback.observation_id))

        {:error, _} ->
          conn
          |> put_flash(:error, "Feedback deletion failed")
          |> redirect(to: Routes.feedback_path(conn, :index, feedback.observation_id))
      end
    end
  end
end
