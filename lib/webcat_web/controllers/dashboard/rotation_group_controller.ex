defmodule WebCATWeb.RotationGroupController do
  use WebCATWeb, :controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Rotation, RotationGroup}

  @list_preload ~w(students users)a
  @preload [rotation: [section: [semester: [:classroom]]]] ++ @list_preload
  @rotation_preload [section: [semester: [:classroom]]]

  def index(conn, %{"rotation_id" => rotation_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(RotationGroup, :list, user),
         {:ok, rotation} <- CRUD.get(Rotation, rotation_id, preload: @rotation_preload),
         rotation_groups <- CRUD.list(RotationGroup, preload: @list_preload, where: [rotation_id: rotation_id]) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        rotation: rotation,
        rotation_groups: rotation_groups
      )
    end
  end

  def show(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, rotation_group} <- CRUD.get(RotationGroup, id, preload: @preload),
         :ok <- Bodyguard.permit(RotationGroup, :show, user, rotation_group) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        rotation_group: rotation_group
      )
    end
  end

  def new(conn, %{"rotation_id" => rotation_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(RotationGroup, :create, user),
         {:ok, rotation} <- CRUD.get(Rotation, rotation_id, preload: @rotation_preload) do
      conn
      |> render("new.html",
        user: user,
        changeset: RotationGroup.changeset(%RotationGroup{}, %{}),
        rotation: rotation,
        selected: "classroom"
      )
    end
  end

  def create(conn, %{"rotation_group" => params}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(RotationGroup, :create, user) do
      case CRUD.create(RotationGroup, params) do
        {:ok, rotation_group} ->
          conn
          |> put_flash(:info, "RotationGroup created!")
          |> redirect(to: Routes.rotation_group_path(conn, :show, rotation_group.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          {:ok, rotation} = CRUD.get(Rotation, params["rotation_id"], preload: @rotation_preload)

          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom",
            rotation: rotation
          )
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, rotation_group} <- CRUD.get(RotationGroup, id, preload: @preload),
         :ok <- Bodyguard.permit(RotationGroup, :update, user, rotation_group) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: RotationGroup.changeset(rotation_group)
      )
    end
  end

  def update(conn, %{"id" => id, "rotation_group" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, rotation_group} <- CRUD.get(RotationGroup, id, preload: @preload),
         :ok <- Bodyguard.permit(RotationGroup, :update, user, rotation_group) do
      case CRUD.update(RotationGroup, rotation_group, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "RotationGroup updated!")
          |> redirect(to: Routes.rotation_group_path(conn, :show, id))

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

    with {:ok, rotation_group} <- CRUD.get(RotationGroup, id),
         :ok <- Bodyguard.permit(RotationGroup, :delete, user, rotation_group) do
      case CRUD.delete(RotationGroup, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "RotationGroup deleted successfully")
          |> redirect(to: Routes.rotation_group_path(conn, :index, rotation_group.rotation_id))

        {:error, _} ->
          conn
          |> put_flash(:error, "RotationGroup deletion failed")
          |> redirect(to: Routes.rotation_group_path(conn, :index, rotation_group.rotation_id))
      end
    end
  end
end
