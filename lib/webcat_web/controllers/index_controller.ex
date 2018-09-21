defmodule WebCATWeb.IndexController do
  use WebCATWeb, :controller

  alias WebCAT.Accounts.User

  def index(conn, _assigns) do
    case WebCATWeb.Auth.Guardian.Plug.current_resource(conn) do
      %User{} ->
        conn
        |> redirect(to: dashboard_path(conn, :index))
      _ ->
        conn
        |> put_flash(:error, "please log in")
        |> redirect(to: login_path(conn, :index))
    end
  end
end
