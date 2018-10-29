defmodule WebCATWeb.IndexController do
  use WebCATWeb, :controller

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    conn
    |> redirect(to: Routes.dashboard_path(conn, :index))
  end
end
