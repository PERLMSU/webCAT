defmodule WebCATWeb.Auth.ErrorHandler do
  use Phoenix.Controller, namespace: WebCATWeb
  import Plug.Conn

  def auth_error(conn, {type, reason}, _opts) do
    conn
    |> put_status(:unauthorized)
    |> put_view(WebCATWeb.ErrorView)
    |> render("401.json", message: reason)
  end
end
