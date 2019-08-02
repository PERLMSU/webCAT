defmodule WebCATWeb.DraftController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.DraftView
  alias WebCAT.Feedback.Draft
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, params) do
    conn
    |> put_status(200)
    |> put_view(DraftView)
    |> render("list.json",
      drafts:
        CRUD.list(Draft, filter: filter(params, ~w(status user_id reviewer_id rotation_group_id)))
    )
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, draft} <- CRUD.get(Draft, id) do
      conn
      |> put_status(200)
      |> put_view(DraftView)
      |> render("show.json", draft: draft)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, draft} <- CRUD.create(Draft, params) do
      conn
      |> put_status(201)
      |> put_view(DraftView)
      |> render("show.json", draft: draft)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to create draft")}

      {:error, _} = it ->
        it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Draft, id, params) do
      conn
      |> put_status(200)
      |> put_view(DraftView)
      |> render("show.json", draft: updated)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to update draft")}

      {:error, _} = it ->
        it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Draft, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to delete draft")}

      {:error, _} = it ->
        it
    end
  end
end
