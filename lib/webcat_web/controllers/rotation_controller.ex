defmodule WebCATWeb.RotationController do
  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Rotation, Rotations}
  alias WebCATWeb.{RotationView, RotationGroupView}

  action_fallback(WebCATWeb.FallbackController)

  plug(WebCATWeb.Auth.Pipeline)

  def index(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :list_rotations, user),
         rotations <- CRUD.list(Rotation, limit: limit, offset: offset) do
      conn
      |> render(RotationView, "list.json", rotations: rotations)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, rotation} <- CRUD.get(Rotation, id),
         :ok <- Bodyguard.permit(WebCAT.Rotations, :show_rotation, user, rotation) do
      conn
      |> render(RotationView, "show.json", rotation: rotation)
    end
  end

  def create(conn, params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_rotation, user),
         {:ok, rotation} <- CRUD.create(Rotation, params) do
      conn
      |> put_status(:created)
      |> render(RotationView, "show.json", rotation: rotation)
    end
  end

  def update(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_rotation} <- CRUD.get(Rotation, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :update_rotation,
             user,
             subject_rotation
           ),
         {:ok, updated} <- CRUD.update(Rotation, subject_rotation.id, params) do
      conn
      |> render(RotationView, "show.json", rotation: updated)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with {:ok, subject_rotation} <- CRUD.get(Rotation, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :delete_rotation,
             user,
             subject_rotation
           ),
         {:ok, _} <- CRUD.delete(Rotation, subject_rotation.id) do
      send_resp(conn, :ok, "")
    end
  end

  def students(conn, %{"id" => id} = params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, subject_rotation} <- CRUD.get(Rotation, id),
         :ok <-
           Bodyguard.permit(
             WebCAT.Rotations,
             :list_rotation_rotation_groups,
             user,
             subject_rotation
           ),
         rotation_groups <-
           Rotations.rotation_groups(subject_rotation.id, limit: limit, offset: offset) do
      conn
      |> render(RotationGroupView, "list.json", rotation_groups: rotation_groups)
    end
  end
end
