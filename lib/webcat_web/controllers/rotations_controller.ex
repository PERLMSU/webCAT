defmodule WebCATWeb.RotationsController do
  @moduledoc """
  Render the main
  """

  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Rotations.{Classroom, Rotation}

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :list_rotations, user),
         rotations <- CRUD.list(Rotation) do
      render(conn, "index.html", rotations: rotations, user: user)
    end
  end

  def show(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :show_rotation, user),
         {:ok, rotation} <- CRUD.get(Rotation, id, preload: [:rotations]) do
      render(conn, "show.html", rotation: rotation, user: user)
    end
  end

  def new(conn, _assigns) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_rotation, user),
         :ok <- Bodyguard.permit(WebCAT.Rotations, :list_classrooms, user) do
      render(conn, "new.html",
        changeset: Rotation.changeset(%Rotation{}),
        user: user,
        classrooms: CRUD.list(Classroom)
      )
    end
  end

  def create(conn, %{"rotation" => %{} = params}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :create_rotation, user) do
      case CRUD.create(Rotation, params) do
        {:ok, _rotation} ->
          conn
          |> put_flash(:info, "Rotation created!")
          |> redirect(to: Routes.dashboard_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset, user: user)
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :update_rotation, user),
         {:ok, rotation} <- CRUD.get(Rotation, id, preload: [:classroom]) do
      render(conn, "edit.html",
        changeset: Rotation.changeset(rotation),
        user: user,
        classrooms: CRUD.list(Classroom)
      )
    end
  end

  def update(conn, %{"id" => id, "rotation" => %{} = params}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :update_rotation, user) do
      case CRUD.update(Rotation, id, params) do
        {:ok, _rotation} ->
          conn
          |> put_flash(:info, "Rotation updated!")
          |> redirect(to: Routes.dashboard_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "edit.html", changeset: changeset, user: user)
      end
    end
  end

  def delete(conn, %{"id" => id}) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :delete_rotation, user),
         {:ok, _rotation} <- CRUD.delete(Rotation, id) do
      conn
      |> put_flash(:info, "Rotation deleted!")
      |> redirect(to: Routes.dashboard_path(conn, :index))
    end
  end
end
