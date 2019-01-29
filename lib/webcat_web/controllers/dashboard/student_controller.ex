defmodule WebCATWeb.StudentController do
  use WebCATWeb, :controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.Student

  @preload [:notes, :sections, rotation_groups: ~w(students)a]

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Student, :list, user),
         students <- CRUD.list(Student, preload: @preload) do
      render(conn, "index.html", user: user, selected: "students", data: students)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, student} <- CRUD.get(Student, id, preload: @preload),
         :ok <- Bodyguard.permit(Student, :show, user, student) do
      render(conn, "show.html", user: user, selected: "students", data: student)
    end
  end

  def new(conn, _params) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Student, :create, user) do
      conn
      |> render("new.html",
        user: user,
        changeset: Student.changeset(%Student{}),
        selected: "students"
      )
    end
  end

  def create(conn, %{"student" => params}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Student, :create, user) do
      case CRUD.create(Student, params) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Student created!")
          |> redirect(to: Routes.student_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "students"
          )
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, student} <- CRUD.get(Student, id, preload: @preload),
         :ok <- Bodyguard.permit(Student, :update, user, student) do
      render(conn, "edit.html",
        user: user,
        selected: "students",
        changeset: Student.changeset(student)
      )
    end
  end

  def update(conn, %{"id" => id, "student" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, student} <- CRUD.get(Student, id, preload: @preload),
         :ok <- Bodyguard.permit(Student, :update, user, student) do
      case CRUD.update(Student, student, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Student updated!")
          |> redirect(to: Routes.student_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "students",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, student} <- CRUD.get(Student, id),
         :ok <- Bodyguard.permit(Student, :delete, user, student) do
      case CRUD.delete(Student, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Student deleted successfully")
          |> redirect(to: Routes.student_path(conn, :index))

        {:error, _} ->
          conn
          |> put_flash(:error, "Student deletion failed")
          |> redirect(to: Routes.student_path(conn, :index))
      end
    end
  end
end
