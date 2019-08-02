defmodule WebCATWeb.ProfileController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.UserView
  alias WebCAT.Accounts.User
  alias WebCAT.CRUD

  action_fallback(WebCAT.FallbackController)

  def show(conn, user, _params) do
    with {:ok, fetched} <- CRUD.get(User, user.id) do
      conn
      |> put_status(200)
      |> put_view(UserView)
      |> render("show.json", user: fetched)
    end
  end

  def update(conn, user, params) do
    with {:ok, updated} <- CRUD.update(User, user, params) do
      conn
      |> put_status(200)
      |> put_view(UserView)
      |> render("show.json", user: updated)
    end
  end
end
