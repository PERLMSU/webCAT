defmodule WebCATWeb.FeedbackController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.FeedbackView
  alias WebCAT.Feedback.Feedback
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(content observation_id)a,
    filter: ~w(observation_id)a,
    fields: Feedback.__schema__(:fields),
    include: Feedback.__schema__(:associations)

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(FeedbackView)
    |> render("list.json", feedback: CRUD.list(Feedback, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, feedback} <- CRUD.get(Feedback, id, query) do
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
