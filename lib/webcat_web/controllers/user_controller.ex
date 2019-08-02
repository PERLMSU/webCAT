defmodule WebCATWeb.UserController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.UserView
  alias WebCAT.Accounts.User
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, params) do
    conn
    |> put_status(200)
    |> put_view(UserView)
    |> render("list.json", users: CRUD.list(User, filter: filter(params, ~w(active))))
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, user} <- CRUD.get(User, id) do
      conn
      |> put_status(200)
      |> put_view(UserView)
      |> render("show.json", user: user)
    end
  end

  def create(conn, _user, params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, user} <- CRUD.create(User, params) do
      conn
      |> put_status(201)
      |> put_view(UserView)
      |> render("show.json", user: user)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to create user")}
      {:error, _} = it -> it
    end
  end

  def update(conn, _user, %{"id" => id} = params) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, updated} <- CRUD.update(User, id, params) do
      conn
      |> put_status(200)
      |> put_view(UserView)
      |> render("show.json", user: updated)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to update user")}
      {:error, _} = it -> it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, deleted} <- CRUD.delete(User, id) do
      conn
      |> put_status(200)
      |> put_view(UserView)
      |> render("show.json", user: deleted)
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to delete user")}
      {:error, _} = it -> it
    end
  end
end
