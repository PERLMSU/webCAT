defmodule WebCATWeb.UserController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.UserView
  alias WebCAT.Accounts.{Users, User}
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _user, _params) do
    conn
    |> put_status(200)
    |> put_view(UserView)
    |> render("list.json", users: Users.list())
  end

  def show(conn, _user, %{"id" => id}) do
    with {:ok, user} <- Users.get(id) do
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
      {:auth, _} -> {:error, :unauthorized}
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
      {:auth, _} -> {:error, :unauthorized}
      {:error, _} = it -> it
    end
  end

  def delete(conn, _user, %{"id" => id}) do
    permissions do
      has_role(:admin)
    end

    with {:auth, :ok} <- {:auth, is_authorized?()},
         {:ok, _deleted} <- CRUD.delete(User, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} -> {:error, :unauthorized}
      {:error, _} = it -> it
    end
  end
end