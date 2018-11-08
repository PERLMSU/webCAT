defmodule WebCATWeb.DashboardController do
  @moduledoc """
  Render the main
  """

  use WebCATWeb, :controller

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    render(conn, "index.html", user: user)
  end

  def import_export(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    render(conn, "import_export.html", user: user)
  end
end
