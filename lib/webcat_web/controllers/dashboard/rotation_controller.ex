defmodule WebCATWeb.RotationController do
  use WebCATWeb, :controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Section, Rotation}

  @list_preload [rotation_groups: [:students]]
  @preload [section: [semester: [:classroom]]] ++ @list_preload
  @section_preload [semester: [:classroom]]

  action_fallback(WebCATWeb.FallbackController)


  def index(conn, %{"section_id" => section_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Rotation, :list, user),
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

  def show(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, rotation} <- CRUD.get(Rotation, id, preload: @preload),
         :ok <- Bodyguard.permit(Rotation, :show, user, rotation) do
      render(conn, "show.html",
        user: user,
        selected: "classroom",
        rotation: rotation
      )
    end
  end

  def new(conn, %{"section_id" => section_id}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Rotation, :create, user),
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

  def create(conn, %{"rotation" => params}) do
    user = Auth.current_resource(conn)

    with :ok <- Bodyguard.permit(Rotation, :create, user) do
      case CRUD.create(Rotation, params) do
        {:ok, rotation} ->
          conn
          |> put_flash(:info, "Rotation created!")
          |> redirect(to: Routes.rotation_path(conn, :show, rotation.id))

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

  def edit(conn, %{"id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, rotation} <- CRUD.get(Rotation, id, preload: @preload),
         :ok <- Bodyguard.permit(Rotation, :update, user, rotation) do
      render(conn, "edit.html",
        user: user,
        selected: "classroom",
        changeset: Rotation.changeset(rotation)
      )
    end
  end

  def update(conn, %{"id" => id, "rotation" => update}) do
    user = Auth.current_resource(conn)

    with {:ok, rotation} <- CRUD.get(Rotation, id, preload: @preload),
         :ok <- Bodyguard.permit(Rotation, :update, user, rotation) do
      case CRUD.update(Rotation, rotation, update) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Rotation updated!")
          |> redirect(to: Routes.rotation_path(conn, :show, id))

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

    with {:ok, rotation} <- CRUD.get(Rotation, id),
         :ok <- Bodyguard.permit(Rotation, :delete, user, rotation) do
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
