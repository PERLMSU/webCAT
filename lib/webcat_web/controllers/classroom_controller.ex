defmodule WebCATWeb.ClassroomController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.ClassroomView
  alias WebCAT.Rotations.{Classroom, Classrooms}
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, _params) do
    conn
    |> put_status(200)
    |> put_view(ClassroomView)
    |> render("list.json", classrooms: Classrooms.list())
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, classroom} <- Classrooms.get(id) do
      conn
      |> put_status(200)
      |> put_view(ClassroomView)
      |> render("show.json", classroom: classroom)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, classroom} <- CRUD.create(Classroom, params) do
      conn
      |> put_status(201)
      |> put_view(ClassroomView)
      |> render("show.json", classroom: classroom)
    else
      {:auth, _} -> {:error, :unauthorized}
      {:error, _} = it -> it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Classroom, id, params) do
      conn
      |> put_status(200)
      |> put_view(ClassroomView)
      |> render("show.json", classroom: updated)
    else
      {:auth, _} -> {:error, :unauthorized}
      {:error, _} = it -> it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Classroom, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} -> {:error, :unauthorized}
      {:error, _} = it -> it
    end
  end
end
