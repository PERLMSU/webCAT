defmodule WebCATWeb.SectionController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.SectionView
  alias WebCAT.Rotations.Section
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(number semester_id)a,
    filter: ~w(semester_id)a,
    fields: Section.__schema__(:fields),
    include: Section.__schema__(:associations)

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(SectionView)
    |> render("list.json", sections: CRUD.list(Section, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, section} <- CRUD.get(Section, id, query) do
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
end
