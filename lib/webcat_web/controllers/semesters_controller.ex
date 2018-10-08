defmodule WebCATWeb.SemestersController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  alias WebCAT.Rotations.{Semester, Semesters}
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _assigns) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :list_semesters, user),
         semesters <- CRUD.list(Semester) do
      render(conn, "index.html", semesters: semesters, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :show_semester, user),
         {:ok, semester} <- CRUD.get(Semester, id, preload: [:classrooms]) do
      render(conn, "show.html", semester: semester, user: user)
    end
  end

  def new(conn, _assigns) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_semester, user) do
      render(conn, "new.html", changeset: Semester.changeset(%Semester{}), user: user)
    end
  end

  def create(conn, %{"semester" => %{} = params}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_semester, user) do
      case CRUD.create(Semester, params) do
        {:ok, semester} ->
          conn
          |> put_flash(:info, ~s(Semester "#{semester.title}" created!))
          |> redirect(to: semesters_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset, user: user)
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :update_semester, user),
         {:ok, semester} <- CRUD.get(Semester, id) do
      render(conn, "edit.html", changeset: Semester.changeset(semester), user: user)
    end
  end

  def update(conn, %{"id" => id, "semester" => %{} = params}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :update_semester, user) do
      case CRUD.update(Semester, id, params) do
        {:ok, semester} ->
          conn
          |> put_flash(:info, ~s(Semester "#{semester.title}" updated!))
          |> redirect(to: semesters_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", changeset: changeset, user: user)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :delete_semester, user),
         {:ok, semester} <- CRUD.delete(Semester, id) do
      conn
      |> put_flash(:info, ~s(Semester "#{semester.title}" deleted!))
      |> redirect(to: semesters_path(conn, :index))
    end
  end
end
