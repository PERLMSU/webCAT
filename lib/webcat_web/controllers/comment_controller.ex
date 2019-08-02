defmodule WebCATWeb.CommentController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.CommentView
  alias WebCAT.Feedback.Comment
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, %{"draft_id" => _draft_id} = params) do
    conn
    |> put_status(200)
    |> put_view(CommentView)
    |> render("list.json",
      comments: CRUD.list(Comment, filter: filter(params, ~w(draft_id user_id)))
    )
  end

  def show(conn, _user, %{"draft_id" => _draft_id, "id" => id} = params) do
    with {:ok, comment} <- CRUD.get(Comment, id, filter: filter(params, ~w(draft_id user_id))) do
      conn
      |> put_status(200)
      |> put_view(CommentView)
      |> render("show.json", comment: comment)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, comment} <- CRUD.create(Comment, params) do
      conn
      |> put_status(201)
      |> put_view(CommentView)
      |> render("show.json", comment: comment)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to create comment")}

      {:error, _} = it ->
        it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Comment, id, params) do
      conn
      |> put_status(200)
      |> put_view(CommentView)
      |> render("show.json", comment: updated)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to update comment")}

      {:error, _} = it ->
        it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Comment, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to delete comment")}

      {:error, _} = it ->
        it
    end
  end
end
