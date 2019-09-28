defmodule WebCATWeb.ProfileController do
  use WebCATWeb, :authenticated_controller

  alias WebCATWeb.UserView
  alias WebCAT.Accounts.User
  alias WebCAT.CRUD

  action_fallback(WebCAT.FallbackController)

  def show(conn, user, _params) do
      conn
      |> put_status(200)
      |> put_view(UserView)
      |> render("show.json", %{data: user})
  end

  def update(conn, user, params) do
    with {:ok, updated} <- CRUD.update(User, user, params) do
      conn
      |> put_status(200)
      |> put_view(UserView)
      |> render("show.json", %{data: updated})
    end
  end
end
