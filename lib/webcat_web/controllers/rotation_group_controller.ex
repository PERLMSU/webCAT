defmodule WebCATWeb.RotationGroupController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.RotationGroupView
  alias WebCAT.Rotations.RotationGroup
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(number rotation_id)a,
    filter: ~w(rotation_id)a,
    fields: RotationGroup.__schema__(:fields),
    include: RotationGroup.__schema__(:associations)

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(RotationGroupView)
    |> render("list.json", rotation_groups: CRUD.list(RotationGroup, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, rotation_group} <- CRUD.get(RotationGroup, id, query) do
      conn
      |> put_status(200)
      |> put_view(RotationGroupView)
      |> render("show.json", rotation_group: rotation_group)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, rotation_group} <- CRUD.create(RotationGroup, params) do
      conn
      |> put_status(201)
      |> put_view(RotationGroupView)
      |> render("show.json", rotation_group: rotation_group)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to create rotation group")}

      {:error, _} = it ->
        it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(RotationGroup, id, params) do
      conn
      |> put_status(200)
      |> put_view(RotationGroupView)
      |> render("show.json", rotation_group: updated)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to update rotation group")}

      {:error, _} = it ->
        it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(RotationGroup, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to delete rotation group")}

      {:error, _} = it ->
        it
    end
  end
end
