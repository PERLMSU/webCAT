defmodule WebCATWeb.RotationGroupController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{RotationGroup, RotationGroups, Rotations}

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"rotation_id" => rotation_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         rotation_groups <- RotationGroups.list(rotation_id),
         {:ok, rotation} <- Rotations.get(rotation_id) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        rotation_groups: rotation_groups,
        rotation: rotation
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation_group} <- RotationGroups.get(id) do
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
         {:ok, rotation} <- Rotations.get(rotation_id) do
      conn
      |> render("new.html",
        user: user,
        changeset: RotationGroup.changeset(%RotationGroup{rotation_id: rotation_id}),
        selected: "classroom",
        rotation: rotation
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
          |> put_flash(:info, "Rotation Group created!")
          |> redirect(to: Routes.rotation_group_path(conn, :show, rotation_group.id))

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

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation_group} <- RotationGroups.get(id) do
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
         {:ok, rotation_group} <- RotationGroups.get(id) do
      case CRUD.update(RotationGroup, rotation_group, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Rotation Group updated!")
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

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.delete(RotationGroup, id) do
        {:ok, rg} ->
          conn
          |> put_flash(:info, "Rotation Group deleted successfully")
          |> redirect(to: Routes.rotation_group_path(conn, :index, rotation_id: rg.rotation_id))

        {:error, %Ecto.Changeset{}} ->
          conn
          |> put_flash(:error, "Rotation Group deletion failed")
          |> redirect(to: Routes.rotation_group_path(conn, :index))
      end
    end
  end
end
