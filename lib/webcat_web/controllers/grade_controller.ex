defmodule WebCATWeb.GradeController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.GradeView
  alias WebCAT.Feedback.Grade
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(score category_id)a,
    filter: ~w(draft_id category_id)a,
    fields: Grade.__schema__(:fields),
    include: Grade.__schema__(:associations)

  def index(conn, _user, %{"draft_id" => draft_id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.update!(:filter, fn filters -> Keyword.put(filters, :draft_id, draft_id) end)
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(GradeView)
    |> render("list.json", grades: CRUD.list(Grade, query))
  end

  def show(conn, _user, %{"draft_id" => draft_id, "id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.update!(:filter, fn filters -> Keyword.put(filters, :draft_id, draft_id) end)
      |> Map.to_list()

    with {:ok, grade} <- CRUD.get(Grade, id, query) do
      conn
      |> put_status(200)
      |> put_view(GradeView)
      |> render("show.json", grade: grade)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, grade} <- CRUD.create(Grade, params) do
      conn
      |> put_status(201)
      |> put_view(GradeView)
      |> render("show.json", grade: grade)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to create grade")}

      {:error, _} = it ->
        it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Grade, id, params) do
      conn
      |> put_status(200)
      |> put_view(GradeView)
      |> render("show.json", grade: updated)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to update grade")}

      {:error, _} = it ->
        it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Grade, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to delete grade")}

      {:error, _} = it ->
        it
    end
  end
end
