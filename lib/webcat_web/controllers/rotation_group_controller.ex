defmodule WebCATWeb.RotationGroupController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.{RotationGroupView, UserView, CategoryView}
  alias WebCAT.Rotations.RotationGroup
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, params) do
    conn
    |> put_status(200)
    |> put_view(RotationGroupView)
    |> render("list.json",
      rotation_groups: CRUD.list(RotationGroup, filter: filter(params, ~w(rotation_id)))
    )
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, rotation_group} <- CRUD.get(RotationGroup, id) do
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
         {:ok, deleted} <- CRUD.delete(RotationGroup, id) do
      conn
      |> put_status(200)
      |> put_view(RotationGroupView)
      |> render("show.json", rotation_group: deleted)
    else
      {:auth, _} ->
        {:error, :forbidden, dgettext("errors", "Not authorized to delete rotation group")}

      {:error, _} = it ->
        it
    end
  end

  def students(conn, _user, %{"id" => id}) do
    with students <- RotationGroup.students(id) do
      conn
      |> put_status(200)
      |> put_view(UserView)
      |> render("list.json", users: students)
    end
  end

  def classroom(conn, _user, %{"id" => id}) do
    with {:ok, classroom} <- RotationGroup.classroom(id) do
      conn
      |> put_status(200)
      |> put_view(ClassroomView)
      |> render("show.json", classroom: classroom)
    else
      _ -> {:error, :not_found}
    end
  end

  def classroom_categories(conn, _user, %{"id" => id}) do
    with categories <- RotationGroup.categories(id) do
      conn
      |> put_status(200)
      |> put_view(CategoryView)
      |> render("list.json", categories: categories)
    else
      _ -> {:error, :not_found}
    end
  end
end
