defmodule WebCATWeb.RotationGroupController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Rotation, RotationGroup}

  @list_preload [users: [performer: ~w(roles)a]]
  @preload [rotation: [section: [semester: [:classroom]]]] ++ @list_preload
  @rotation_preload [section: [semester: [:classroom]]]

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"rotation_id" => rotation_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation} <- CRUD.get(Rotation, rotation_id, preload: @rotation_preload),
         rotation_groups <-
           CRUD.list(RotationGroup, preload: @list_preload, where: [rotation_id: rotation_id]) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        rotation: rotation,
        rotation_groups: rotation_groups
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation_group} <- CRUD.get(RotationGroup, id, preload: @preload) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        rotation_group: rotation_group
      )
    end
  end

  def new(conn, user, %{"rotation_id" => rotation_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
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

  def create(conn, user, %{"rotation_group" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(RotationGroup, params) do
        {:ok, rotation_group} ->
          conn
          |> put_flash(:info, "RotationGroup created!")
          |> redirect(to: Routes.rotation_group_path(conn, :show, rotation_group.rotation_id, rotation_group.id))

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

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation_group} <- CRUD.get(RotationGroup, id, preload: @preload) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: RotationGroup.changeset(rotation_group)
      )
    end
  end

  def update(conn, user, %{"id" => id, "rotation_group" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation_group} <- CRUD.get(RotationGroup, id, preload: @preload) do
      case CRUD.update(RotationGroup, rotation_group, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "RotationGroup updated!")
          |> redirect(to: Routes.rotation_group_path(conn, :show, rotation_group.rotation_id, id))

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
         {:ok, rotation_group} <- CRUD.get(RotationGroup, id) do
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
