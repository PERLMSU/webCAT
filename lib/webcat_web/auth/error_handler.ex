defmodule WebCATWeb.Auth.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, {type, reason}, _opts) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, Jason.encode!(%{error: to_string(type), message: reason}))
  end
end
