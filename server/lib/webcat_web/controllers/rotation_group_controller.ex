defmodule WebCATWeb.RotationGroupController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Rotations.{RotationGroup, RotationGroups}
  alias WebCATWeb.{RotationGroupView, DraftView, StudentView}

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :list_rotation_groups, user),
         rotation_groups <- CRUD.list(RotationGroup, limit: limit, offset: offset) do
      conn
      |> render(RotationGroupView, "list.json", rotation_groups: rotation_groups)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, rotation_group} <- CRUD.get(RotationGroup, id),
         :ok <- Bodyguard.permit(WebCAT.Rotations, :show_rotation_group, user, rotation_group) do
      conn
      |> render(RotationGroupView, "show.json", rotation_group: rotation_group)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_rotation_group, user),
         {:ok, rotation_group} <- CRUD.create(RotationGroup, params) do
      conn
      |> put_status(:created)
      |> render(RotationGroupView, "show.json", rotation_group: rotation_group)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_rotation_group} <- CRUD.get(RotationGroup, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :update_rotation_group,
             user,
             subject_rotation_group
           ),
         {:ok, updated} <- CRUD.update(RotationGroup, subject_rotation_group.id, params) do
      conn
      |> render(RotationGroupView, "show.json", rotation_group: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_rotation_group} <- CRUD.get(RotationGroup, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :delete_rotation_group,
             user,
             subject_rotation_group
           ),
         {:ok, _} <- CRUD.delete(RotationGroup, subject_rotation_group.id) do
      send_resp(conn, :ok, "")
    end
  end

  def drafts(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_rotation_group} <- CRUD.get(RotationGroup, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_rotation_group_drafts,
             user,
             subject_rotation_group
           ),
         drafts <- RotationGroups.drafts(subject_rotation_group.id, limit: limit, offset: offset) do
      conn
      |> render(DraftView, "list.json", drafts: drafts)
    end
  end

  def students(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_rotation_group} <- CRUD.get(RotationGroup, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_rotation_group_students,
             user,
             subject_rotation_group
           ),
         students <-
           RotationGroups.students(subject_rotation_group.id, limit: limit, offset: offset) do
      conn
      |> render(StudentView, "list.json", students: students)
    end
  end
end
