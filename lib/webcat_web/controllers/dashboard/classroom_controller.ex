defmodule WebCATWeb.ClassroomController do
  use WebCATWeb, :controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.Classroom

  @preload [:users, semesters: ~w(sections)a]

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Classroom, :list, user),
         classrooms <- CRUD.list(Classroom, preload: @preload) do
      render(conn, "index.html", user: user, selected: "classroom", data: classrooms)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, classroom} <- CRUD.get(Classroom, id, preload: @preload),
         :ok <- Bodyguard.permit(Classroom, :show, user, classroom) do
      render(conn, "show.html", user: user, selected: "classroom", data: classroom)
    end
  end

  def new(conn, _params) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Classroom, :create, user) do
      conn
      |> render("new.html",
        user: user,
        changeset: Classroom.changeset(%Classroom{}),
        selected: "classroom"
      )
    end
  end

  def create(conn, %{"classroom" => params}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Classroom, :create, user) do
      case CRUD.create(Classroom, params) do
        {:ok, classroom} ->
          conn
          |> put_flash(:info, "Classroom created!")
          |> redirect(to: Routes.classroom_path(conn, :show, classroom.id))

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

    with {:ok, classroom} <- CRUD.get(Classroom, id, preload: @preload),
         :ok <- Bodyguard.permit(Classroom, :update, user, classroom) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Classroom.changeset(classroom)
      )
    end
  end

  def update(conn, %{"id" => id, "classroom" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, classroom} <- CRUD.get(Classroom, id, preload: @preload),
         :ok <- Bodyguard.permit(Classroom, :update, user, classroom) do
      case CRUD.update(Classroom, classroom, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Classroom updated!")
          |> redirect(to: Routes.classroom_path(conn, :show, id))

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

    with {:ok, classroom} <- CRUD.get(Classroom, id),
         :ok <- Bodyguard.permit(Classroom, :delete, user, classroom) do
      case CRUD.delete(Classroom, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Classroom deleted successfully")
          |> redirect(to: Routes.classroom_path(conn, :index))

        {:error, _} ->
          conn
          |> put_flash(:error, "Classroom deletion failed")
          |> redirect(to: Routes.classroom_path(conn, :index))
      end
    end
  end

  def import(conn, _params) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Classroom, :import, user) do
      render(conn, "import.html", user: user, selected: "classroom")
    end
  end

  def handle_import(conn, %{"file" => %{"data" => %{path: path}}}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Classroom, :import, user),
         {:ok, import_result} <- WebCAT.Import.import(:classrooms, path) do
      %{ok: ok_count, error: error_count} = import_result

      conn
      |> put_flash(
        :info,
        "#{ok_count} classrooms imported successfully.\n#{error_count} classrooms failed importing."
      )
      |> redirect(to: Routes.classroom_path(conn, :index))
    end
  end
end
