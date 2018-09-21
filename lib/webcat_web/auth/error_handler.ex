defmodule WebCATWeb.Auth.ErrorHandler do
  use WebCATWeb, :controller

  def auth_error(conn, {_type, _reason}, _opts) do
    conn
    |> put_flash(:error, "please log in to view this page")
    |> redirect(to: login_path(conn, :index))
  end
end
