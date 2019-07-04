defmodule WebCATWeb.RotationController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.RotationView
  alias WebCAT.Rotations.Rotation
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(number start_date end_date section_id)a,
    filter: ~w(section_id)a,
    fields: Rotation.__schema__(:fields),
    include: Rotation.__schema__(:associations)

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(RotationView)
    |> render("list.json", rotations: CRUD.list(Rotation, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, rotation} <- CRUD.get(Rotation, id, query) do
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
