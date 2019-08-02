defmodule WebCATWeb.RotationController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.RotationView
  alias WebCAT.Rotations.Rotation
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, params) do
    conn
    |> put_status(200)
    |> put_view(RotationView)
    |> render("list.json", rotations: CRUD.list(Rotation, filter: filter(params, ~w(section_id))))
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, rotation} <- CRUD.get(Rotation, id) do
      conn
      |> put_status(200)
      |> put_view(RotationView)
      |> render("show.json", rotation: rotation)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, rotation} <- CRUD.create(Rotation, params) do
      conn
      |> put_status(201)
      |> put_view(RotationView)
      |> render("show.json", rotation: rotation)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to create rotation")}
      {:error, _} = it -> it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Rotation, id, params) do
      conn
      |> put_status(200)
      |> put_view(RotationView)
      |> render("show.json", rotation: updated)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to update rotation")}
      {:error, _} = it -> it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Rotation, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to delete rotation")}
      {:error, _} = it -> it
    end
  end
end
