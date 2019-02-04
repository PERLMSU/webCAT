defmodule WebCATWeb.SemesterController do
  use WebCATWeb, :controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Classroom, Semester}

  @list_preload ~w(sections)a
  @preload [:classroom, sections: ~w(rotations users students)a]

  def index(conn, %{"classroom_id" => classroom_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Semester, :list, user),
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

  def show(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, semester} <- CRUD.get(Semester, id, preload: @preload),
         :ok <- Bodyguard.permit(Semester, :show, user, semester) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        semester: semester
      )
    end
  end

  def new(conn, %{"classroom_id" => classroom_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Semester, :create, user),
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

  def create(conn, %{"semester" => params}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Semester, :create, user) do
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

  def edit(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, semester} <- CRUD.get(Semester, id, preload: @preload),
         :ok <- Bodyguard.permit(Semester, :update, user, semester) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Semester.changeset(semester)
      )
    end
  end

  def update(conn, %{"id" => id, "semester" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, semester} <- CRUD.get(Semester, id, preload: @preload),
         :ok <- Bodyguard.permit(Semester, :update, user, semester) do
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

  def delete(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, semester} <- CRUD.get(Semester, id),
         :ok <- Bodyguard.permit(Semester, :delete, user, semester) do
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
