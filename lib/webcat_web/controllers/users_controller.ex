defmodule WebCATWeb.UsersController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  alias WebCAT.CRUD
  alias WebCAT.Accounts.User

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Accounts, :list_users, user),
         users <- CRUD.list(User) do
      render(conn, "index.html", conn: conn, user: user, users: users)
    end
  end
end
