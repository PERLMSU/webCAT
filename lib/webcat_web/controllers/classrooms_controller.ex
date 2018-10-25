defmodule WebCATWeb.ClassroomsController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Classroom, Semester}

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :list_classrooms, user),
         classrooms <- CRUD.list(Classroom) do
      render(conn, "index.html", classrooms: classrooms, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :show_classroom, user),
         {:ok, classroom} <-
           CRUD.get(Classroom, id, preload: [:semester, :rotations, :students, :instructors]) do
      render(conn, "show.html", classroom: classroom, user: user)
    end
  end

  def new(conn, _assigns) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_classroom, user),
         :ok <- Bodyguard.permit(WebCAT.Rotations, :list_semesters, user) do
      render(conn, "new.html",
        changeset: Classroom.changeset(%Classroom{}),
        user: user,
        semesters: CRUD.list(Semester)
      )
    end
  end

  def create(conn, %{"classroom" => %{} = params}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_classroom, user) do
      case CRUD.create(Classroom, params) do
        {:ok, classroom} ->
          conn
          |> put_flash(:info, ~s(Classroom "#{classroom.course_code}" created!))
          |> redirect(to: Routes.classrooms_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html",
            changeset: changeset,
            user: user,
            semesters: CRUD.list(Semester)
          )
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :update_classroom, user),
         {:ok, classroom} <- CRUD.get(Classroom, id, preload: [:semester]) do
      render(conn, "edit.html",
        changeset: Classroom.changeset(classroom),
        user: user,
        semesters: CRUD.list(Semester)
      )
    end
  end

  def update(conn, %{"id" => id, "classroom" => %{} = params}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :update_classroom, user) do
      case CRUD.update(Classroom, id, params) do
        {:ok, classroom} ->
          conn
          |> put_flash(:info, ~s(Classroom "#{classroom.course_code}" updated!))
          |> redirect(to: Routes.classrooms_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            changeset: changeset,
            user: user,
            semesters: CRUD.list(Semester)
          )
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :delete_classroom, user),
         {:ok, classroom} <- CRUD.delete(Classroom, id) do
      conn
      |> put_flash(:info, ~s(Classroom "#{classroom.course_code}" deleted!))
      |> redirect(to: Routes.classrooms_path(conn, :index))
    end
  end
end
