defmodule WebCATWeb.DraftController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Feedback.Draft
  alias WebCATWeb.DraftView

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :list_drafts, user),
         drafts <- CRUD.list(Draft, limit: limit, offset: offset) do
      conn
      |> render(DraftView, "list.json", drafts: drafts)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, draft} <- CRUD.get(Draft, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :show_draft, user, draft) do
      conn
      |> render(DraftView, "show.json", draft: draft)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :create_draft, user),
         {:ok, draft} <- CRUD.create(Draft, params) do
      conn
      |> put_status(:created)
      |> render(DraftView, "show.json", draft: draft)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_draft} <- CRUD.get(Draft, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :update_draft, user, subject_draft),
         {:ok, updated} <- CRUD.update(Draft, subject_draft.id, params) do
      conn
      |> render(DraftView, "show.json", draft: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_draft} <- CRUD.get(Draft, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :delete_draft, user, subject_draft),
         {:ok, _} <- CRUD.delete(Draft, subject_draft.id) do
      send_resp(conn, :ok, "")
    end
  end
end
