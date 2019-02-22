defmodule WebCATWeb.SemesterController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Classroom, Semester}

  @list_preload ~w(sections)a
  @preload [:classroom, sections: ~w(rotations students)a]

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"classroom_id" => classroom_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, classroom} <- CRUD.get(Classroom, classroom_id),
         semesters <-
           CRUD.list(Semester, preload: @list_preload, where: [classroom_id: classroom_id]) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        classroom: classroom,
        semesters: semesters
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, semester} <- CRUD.get(Semester, id, preload: @preload) do
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
        changeset: Semester.changeset(%Semester{}, %{}),
        classroom: classroom,
        selected: "classroom"
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
          |> redirect(to: Routes.semester_path(conn, :show, semester.classroom_id, semester.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          with {:ok, classroom} <- CRUD.get(Classroom, Map.get(params, "classroom_id")) do
            conn
            |> render("new.html",
              user: user,
              changeset: changeset,
              selected: "classroom",
              classroom: classroom
              )
          end
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, semester} <- CRUD.get(Semester, id, preload: @preload) do
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
         {:ok, semester} <- CRUD.get(Semester, id, preload: @preload) do
      case CRUD.update(Semester, semester, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Semester updated!")
          |> redirect(to: Routes.semester_path(conn, :show, semester.classroom_id, id))

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

    with :ok <- is_authorized?(),
         {:ok, semester} <- CRUD.get(Semester, id) do
      case CRUD.delete(Semester, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Semester deleted successfully")
          |> redirect(to: Routes.semester_path(conn, :index, semester.classroom_id))

        {:error, _} ->
          conn
          |> put_flash(:error, "Semester deletion failed")
          |> redirect(to: Routes.semester_path(conn, :index, semester.classroom_id))
      end
    end
  end
end
