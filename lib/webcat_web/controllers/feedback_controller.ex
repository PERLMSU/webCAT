defmodule WebCATWeb.FeedbackController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.FeedbackView
  alias WebCAT.Feedback.Feedback
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, params) do
    conn
    |> put_status(200)
    |> put_view(FeedbackView)
    |> render("list.json", feedback: CRUD.list(Feedback, filter: filter(params, ~w(observation_id))))
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, feedback} <- CRUD.get(Feedback, id) do
      conn
      |> put_status(200)
      |> put_view(FeedbackView)
      |> render("show.json", feedback: feedback)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, feedback} <- CRUD.create(Feedback, params) do
      conn
      |> put_status(201)
      |> put_view(FeedbackView)
      |> render("show.json", feedback: feedback)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to create feedback")}
      {:error, _} = it -> it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Feedback, id, params) do
      conn
      |> put_status(200)
      |> put_view(FeedbackView)
      |> render("show.json", feedback: updated)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to update feedback")}
      {:error, _} = it -> it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Feedback, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to delete feedback")}
      {:error, _} = it -> it
    end
  end
end
