defmodule WebCATWeb.SemesterController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Semester, Semesters, Classroom}

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"classroom_id" => classroom_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         semesters <- Semesters.list(classroom_id),
         {:ok, classroom} <- CRUD.get(Classroom, classroom_id) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        semesters: semesters,
        classroom: classroom
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, semester} <- Semesters.get(id) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        semester: semester
      )
    end
  end

  def new(conn, user, %{"classroom_id" => classroom_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, classroom} <- CRUD.get(Classroom, classroom_id) do
      conn
      |> render("new.html",
        user: user,
        changeset: Semester.changeset(%Semester{classroom_id: classroom_id}),
        selected: "classroom",
        classroom: classroom
      )
    end
  end

  def create(conn, user, %{"semester" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(Semester, params) do
        {:ok, semester} ->
          conn
          |> put_flash(:info, "Semester created!")
          |> redirect(to: Routes.semester_path(conn, :show, semester.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom"
          )
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, semester} <- Semesters.get(id) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Semester.changeset(semester)
      )
    end
  end

  def update(conn, user, %{"id" => id, "semester" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, semester} <- Semesters.get(id) do
      case CRUD.update(Semester, semester, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Semester updated!")
          |> redirect(to: Routes.semester_path(conn, :show, id))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "classroom",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.delete(Semester, id) do
        {:ok, semester} ->
          conn
          |> put_flash(:info, "Semester deleted successfully")
          |> redirect(to: Routes.semester_path(conn, :index, classroom_id: semester.classroom_id))

        {:error, %Ecto.Changeset{}} ->
          conn
          |> put_flash(:error, "Semester deletion failed")
          |> redirect(to: Routes.semester_path(conn, :index))
      end
    end
  end
end
