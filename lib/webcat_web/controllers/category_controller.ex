defmodule WebCATWeb.CategoryController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.CategoryView
  alias WebCAT.Feedback.Category
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, params) do
    conn
    |> put_status(200)
    |> put_view(CategoryView)
    |> render("list.json",
      categories: CRUD.list(Category, filter: filter(params, ~w(parent_category_id classroom_id)))
    )
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, category} <- CRUD.get(Category, id) do
      conn
      |> put_status(200)
      |> put_view(CategoryView)
      |> render("show.json", category: category)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, category} <- CRUD.create(Category, params) do
      conn
      |> put_status(201)
      |> put_view(CategoryView)
      |> render("show.json", category: category)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to create category")}
      {:error, _} = it -> it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(Category, id, params) do
      conn
      |> put_status(200)
      |> put_view(CategoryView)
      |> render("show.json", category: updated)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to update category")}
      {:error, _} = it -> it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(Category, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to delete category")}
      {:error, _} = it -> it
    end
  end
end
