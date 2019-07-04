defmodule WebCATWeb.UserController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.UserView
  alias WebCAT.Accounts.User
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  plug WebCATWeb.Plug.Query,
    sort: ~w(email first_name last_name middle_name nickname active)a,
    filter: ~w(active)a,
    fields: User.__schema__(:fields) |> List.delete(:performer_id),
    include: User.__schema__(:associations) |> Enum.reject(&(&1 in ~w(performer notifications)a))

  def index(conn, _user, _params) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    conn
    |> put_status(200)
    |> put_view(UserView)
    |> render("list.json", users: CRUD.list(User, query))
  end

  def show(conn, _user, %{"id" => id}) do
    query =
      conn.assigns.parsed_query
      |> Map.from_struct()
      |> Map.to_list()

    with {:ok, user} <- CRUD.get(User, id, query) do
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
         {:ok, _deleted} <- CRUD.delete(User, id) do
      conn
      |> put_status(204)
      |> text("")
    else
      {:auth, _} -> {:error, :forbidden, dgettext("errors", "Not authorized to delete user")}
      {:error, _} = it -> it
    end
  end
end
