defmodule WebCATWeb.SemesterController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.SemesterView
  alias WebCAT.Rotations.{Semester, Semesters}
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, _params) do
    conn
    |> put_status(200)
    |> put_view(SemesterView)
    |> render("list.json", semesters: Semesters.list())
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, semester} <- Semesters.get(id) do
      conn
      |> put_status(200)
      |> put_view(SemesterView)
      |> render("show.json", semester: semester)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, semester} <- CRUD.create(Semester, params) do
      conn
      |> put_status(201)
      |> put_view(SemesterView)
      |> render("show.json", semester: semester)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to create semester")}
      {:error, _} = it -> it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Semester, id, params) do
      conn
      |> put_status(200)
      |> put_view(SemesterView)
      |> render("show.json", semester: updated)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to update semester")}
      {:error, _} = it -> it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Semester, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to delete semester")}
      {:error, _} = it -> it
    end
  end
end
