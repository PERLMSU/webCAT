defmodule WebCATWeb.ClassroomController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Classroom, Classrooms}
  alias WebCATWeb.{ClassroomView, UserView, RotationView, StudentView}

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :list_classrooms, user),
         classrooms <- CRUD.list(Classroom, limit: limit, offset: offset) do
      conn
      |> render(ClassroomView, "list.json", classrooms: classrooms)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, classroom} <- CRUD.get(Classroom, id),
         :ok <- Bodyguard.permit(WebCAT.Rotations, :show_classroom, user, classroom) do
      conn
      |> render(ClassroomView, "show.json", classroom: classroom)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_classroom, user),
         {:ok, classroom} <- CRUD.create(Classroom, params) do
      conn
      |> put_status(:created)
      |> render(ClassroomView, "show.json", classroom: classroom)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_classroom} <- CRUD.get(Classroom, id),
         :ok <- Bodyguard.permit(WebCAT.Rotations, :update_classroom, user, subject_classroom),
         {:ok, updated} <- CRUD.update(Classroom, subject_classroom.id, params) do
      conn
      |> render(ClassroomView, "show.json", classroom: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_classroom} <- CRUD.get(Classroom, id),
         :ok <- Bodyguard.permit(WebCAT.Rotations, :delete_classroom, user, subject_classroom),
         {:ok, _} <- CRUD.delete(Classroom, subject_classroom.id) do
      send_resp(conn, :ok, "")
    end
  end

  def instructors(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_classroom} <- CRUD.get(Classroom, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_classroom_instructors,
             user,
             subject_classroom
           ),
         instructors <- Classrooms.instructors(subject_classroom.id, limit: limit, offset: offset) do
      conn
      |> render(UserView, "list.json", users: instructors)
    end
  end

  def rotations(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_classroom} <- CRUD.get(Classroom, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_classroom_rotations,
             user,
             subject_classroom
           ),
         rotations <- Classrooms.rotations(subject_classroom.id, limit: limit, offset: offset) do
      conn
      |> render(RotationView, "list.json", rotations: rotations)
    end
  end

  def students(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_classroom} <- CRUD.get(Classroom, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_classroom_students,
             user,
             subject_classroom
           ),
         students <- Classrooms.students(subject_classroom.id, limit: limit, offset: offset) do
      conn
      |> render(StudentView, "list.json", students: students)
    end
  end
end
