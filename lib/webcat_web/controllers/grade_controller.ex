defmodule WebCATWeb.GradeController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.GradeView
  alias WebCAT.Feedback.Grade
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, %{"draft_id" => _draft_id} = params) do
    conn
    |> put_status(200)
    |> put_view(GradeView)
    |> render("list.json",
      grades: CRUD.list(Grade, filter: filter(params, ~w(draft_id category_id)))
    )
  end

  def show(conn, _user, %{"draft_id" => _draft_id, "id" => id} = params) do
    with {:ok, grade} <- CRUD.get(Grade, id, filter: filter(params, ~w(draft_id category_id))) do
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
