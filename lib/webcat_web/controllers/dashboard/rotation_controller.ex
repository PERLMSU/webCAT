defmodule WebCATWeb.RotationController do
  use WebCATWeb, :authenticated_controller
  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Rotation, Rotations, Sections}

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, %{"section_id" => section_id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         rotations <- Rotations.list(section_id),
         {:ok, section} <- Sections.get(section_id) do
      render(conn, "index.html",
        user: user,
        selected: "classroom",
        rotations: rotations,
        section: section
      )
    end
  end

  def show(conn, user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?(),
         {:ok, rotation} <- Rotations.get(id) do
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
         {:ok, section} <- Sections.get(section_id) do
      conn
      |> render("new.html",
        user: user,
        changeset: Rotation.changeset(%Rotation{section_id: section_id}),
        selected: "classroom",
        section: section
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
          |> redirect(to: Routes.rotation_path(conn, :show, rotation.id))

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
         {:ok, rotation} <- Rotations.get(id) do
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
         {:ok, rotation} <- Rotations.get(id) do
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

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with :ok <- is_authorized?() do
      case CRUD.delete(Rotation, id) do
        {:ok, rotation} ->
          conn
          |> put_flash(:info, "Rotation deleted successfully")
          |> redirect(to: Routes.rotation_path(conn, :index, section_id: rotation.section_id))

        {:error, %Ecto.Changeset{}} ->
          conn
          |> put_flash(:error, "Rotation deletion failed")
          |> redirect(to: Routes.rotation_path(conn, :index))
      end
    end
  end
end
