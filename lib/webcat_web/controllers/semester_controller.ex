defmodule WebCATWeb.SemesterController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.SemesterView
  alias WebCAT.Rotations.Semester
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(name start_date end_date)a,
    filter: ~w(classroom_id)a,
    fields: Semester.__schema__(:fields),
    include: Semester.__schema__(:associations)

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(SemesterView)
    |> render("list.json", semesters: CRUD.list(Semester, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, semester} <- CRUD.get(Semester, id, query) do
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
