defmodule WebCATWeb.SectionController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.SectionView
  alias WebCAT.Rotations.Section
  alias WebCAT.CRUD
  alias WebCAT.Import.Students, as: Import

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, params) do
    conn
    |> put_status(200)
    |> put_view(SectionView)
    |> render("list.json", sections: CRUD.list(Section, filter: filter(params, ~w(semester_id))))
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, section} <- CRUD.get(Section, id) do
      conn
      |> put_status(200)
      |> put_view(SectionView)
      |> render("show.json", section: section)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, section} <- CRUD.create(Section, params) do
      conn
      |> put_status(201)
      |> put_view(SectionView)
      |> render("show.json", section: section)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to create section")}
      {:error, _} = it -> it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Section, id, params) do
      conn
      |> put_status(200)
      |> put_view(SectionView)
      |> render("show.json", section: updated)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to update section")}
      {:error, _} = it -> it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Section, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to delete section")}
      {:error, _} = it -> it
    end
  end

  def import(conn, _user, %{"id" => id, "file" => %{path: path}}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _section} <- CRUD.get(Section, id),
         :ok <- Import.import(id, path) do
      conn
      |> put_status(201)
      |> text("")
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to import data")}
      {:error, _} = it -> it
    end
  end
end
