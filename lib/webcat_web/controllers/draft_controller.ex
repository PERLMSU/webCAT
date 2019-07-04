defmodule WebCATWeb.DraftController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.DraftView
  alias WebCAT.Feedback.Draft
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(status user_id reviewer_id rotation_group_id)a,
    filter: ~w(status user_id reviewer_id rotation_group_id)a,
    fields: Draft.__schema__(:fields),
    include: Draft.__schema__(:associations)

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(DraftView)
    |> render("list.json", drafts: CRUD.list(Draft, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, draft} <- CRUD.get(Draft, id, query) do
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
