defmodule WebCATWeb.RotationController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Section, Rotation}

  @list_preload [rotation_groups: [:users]]
  @preload [section: [semester: [:classroom]]] ++ @list_preload
  @section_preload [semester: [:classroom]]

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"section_id" => section_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, section} <- CRUD.get(Section, section_id, preload: @section_preload),
         rotations <- CRUD.list(Rotation, preload: @list_preload, where: [section_id: section_id]) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        section: section,
        rotations: rotations
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation} <- CRUD.get(Rotation, id, preload: @preload) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        rotation: rotation
      )
    end
  end

  def new(conn, user, %{"section_id" => section_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, section} <- CRUD.get(Section, section_id, preload: @section_preload) do
      conn
      |> render("new.html",
        user: user,
        changeset: Rotation.changeset(%Rotation{}, %{}),
        section: section,
        selected: "classroom"
      )
    end
  end

  def create(conn, user, %{"rotation" => params}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.create(Rotation, params) do
        {:ok, rotation} ->
          conn
          |> put_flash(:info, "Rotation created!")
          |> redirect(to: Routes.rotation_path(conn, :show, rotation.section_id, rotation.id))

        {:error, %Ecto.Changeset{} = changeset} ->
          {:ok, section} = CRUD.get(Section, params["section_id"], preload: @section_preload)

          conn
          |> render("new.html",
            user: user,
            changeset: changeset,
            selected: "classroom",
            section: section
          )
      end
    end
  end

  def edit(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation} <- CRUD.get(Rotation, id, preload: @preload) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Rotation.changeset(rotation)
      )
    end
  end

  def update(conn, user, %{"id" => id, "rotation" => update}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation} <- CRUD.get(Rotation, id, preload: @preload) do
      case CRUD.update(Rotation, rotation, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Rotation updated!")
          |> redirect(to: Routes.rotation_path(conn, :show, rotation.section_id, id))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html",
            user: user,
            selected: "classroom",
            changeset: changeset
          )
      end
    end
  end

  def delete(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation} <- CRUD.get(Rotation, id) do
      case CRUD.delete(Rotation, id) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Rotation deleted successfully")
          |> redirect(to: Routes.rotation_path(conn, :index, rotation.section_id))

        {:error, _} ->
          conn
          |> put_flash(:error, "Rotation deletion failed")
          |> redirect(to: Routes.rotation_path(conn, :index, rotation.section_id))
      end
    end
  end
end
