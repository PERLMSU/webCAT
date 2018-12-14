defmodule WebCATWeb.Auth.ErrorHandler do
  use WebCATWeb, :controller

  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    request_path = Map.fetch!(conn, :request_path)

    conn
    |> put_flash(:error, "please log in to view this page")
    |> redirect(to: Routes.login_path(conn, :index, redirect: request_path))
  end

  def auth_error(conn, {:already_authenticated, _reason}, _opts) do
    redirect(conn, to: Routes.index_path(conn, :index))
  end
end
