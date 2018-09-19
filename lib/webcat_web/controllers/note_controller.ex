defmodule WebCATWeb.NoteController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Feedback.Note
  alias WebCATWeb.NoteView

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :list_notes, user),
         notes <- CRUD.list(Note, limit: limit, offset: offset) do
      conn
      |> render(NoteView, "list.json", notes: notes)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, note} <- CRUD.get(Note, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :show_note, user, note) do
      conn
      |> render(NoteView, "show.json", note: note)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Feedback, :create_note, user),
         {:ok, note} <- CRUD.create(Note, params) do
      conn
      |> put_status(:created)
      |> render(NoteView, "show.json", note: note)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_note} <- CRUD.get(Note, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :update_note, user, subject_note),
         {:ok, updated} <- CRUD.update(Note, subject_note.id, params) do
      conn
      |> render(NoteView, "show.json", note: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_note} <- CRUD.get(Note, id),
         :ok <- Bodyguard.permit(WebCAT.Feedback, :delete_note, user, subject_note),
         {:ok, _} <- CRUD.delete(Note, subject_note.id) do
      send_resp(conn, :ok, "")
    end
  end
end
