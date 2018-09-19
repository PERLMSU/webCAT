defmodule WebCATWeb.SemesterController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Semester, Semesters}
  alias WebCATWeb.{SemesterView, ClassroomView}

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :list_semesters, user),
         semesters <- CRUD.list(Semester, limit: limit, offset: offset) do
      conn
      |> render(SemesterView, "list.json", semesters: semesters)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, semester} <- CRUD.get(Semester, id),
         :ok <- Bodyguard.permit(WebCAT.Rotations, :show_semester, user, semester) do
      conn
      |> render(SemesterView, "show.json", semester: semester)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_semester, user),
         {:ok, semester} <- CRUD.create(Semester, params) do
      conn
      |> put_status(:created)
      |> render(SemesterView, "show.json", semester: semester)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_semester} <- CRUD.get(Semester, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :update_semester,
             user,
             subject_semester
           ),
         {:ok, updated} <- CRUD.update(Semester, subject_semester.id, params) do
      conn
      |> render(SemesterView, "show.json", semester: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_semester} <- CRUD.get(Semester, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :delete_semester,
             user,
             subject_semester
           ),
         {:ok, _} <- CRUD.delete(Semester, subject_semester.id) do
      send_resp(conn, :ok, "")
    end
  end

  def classrooms(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_semester} <- CRUD.get(Semester, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_semester_classrooms,
             user,
             subject_semester
           ),
           classrooms <-
           Semesters.classrooms(subject_semester.id, limit: limit, offset: offset) do
      conn
      |> render(ClassroomView, "list.json", classrooms: classrooms)
    end
  end
end
