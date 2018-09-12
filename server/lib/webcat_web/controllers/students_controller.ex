defmodule WebCATWeb.StudentController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Student, Students}
  alias WebCATWeb.{StudentView, DraftView, NoteView, RotationGroupView}

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :list_students, user),
         students <- CRUD.list(Student, limit: limit, offset: offset) do
      conn
      |> render(StudentView, "list.json", students: students)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, student} <- CRUD.get(Student, id),
         :ok <- Bodyguard.permit(WebCAT.Rotations, :show_student, user, student) do
      conn
      |> render(StudentView, "show.json", student: student)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_student, user),
         {:ok, student} <- CRUD.create(Student, params) do
      conn
      |> put_status(:created)
      |> render(StudentView, "show.json", student: student)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_student} <- CRUD.get(Student, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :update_student,
             user,
             subject_student
           ),
         {:ok, updated} <- CRUD.update(Student, subject_student.id, params) do
      conn
      |> render(StudentView, "show.json", student: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_student} <- CRUD.get(Student, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :delete_student,
             user,
             subject_student
           ),
         {:ok, _} <- CRUD.delete(Student, subject_student.id) do
      send_resp(conn, :ok, "")
    end
  end

  def drafts(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_student} <- CRUD.get(Student, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_student_drafts,
             user,
             subject_student
           ),
         drafts <- Students.drafts(subject_student.id, limit: limit, offset: offset) do
      conn
      |> render(DraftView, "list.json", drafts: drafts)
    end
  end

  def notes(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_student} <- CRUD.get(Student, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_student_notes,
             user,
             subject_student
           ),
           notes <- Students.notes(subject_student.id, limit: limit, offset: offset) do
      conn
      |> render(NoteView, "list.json", notes: notes)
    end
  end

  def rotation_groups(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_student} <- CRUD.get(Student, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_student_rotation_groups,
             user,
             subject_student
           ),
           rotation_groups <- Students.rotation_groups(subject_student.id, limit: limit, offset: offset) do
      conn
      |> render(RotationGroupView, "list.json", rotation_groups: rotation_groups)
    end
  end
end
