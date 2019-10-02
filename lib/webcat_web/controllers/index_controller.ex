defmodule WebCATWeb.IndexController do
  use WebCATWeb, :controller

  alias WebCat

  action_fallback(WebCATWeb.FallbackController)

  def redirect_index(conn, _params) do
    redirect(conn, to: Routes.index_path(conn, :index, []))
  end

  def index(conn, _params) do
    conn
    |> put_resp_header("content-type", "text/html; charset=utf-8")
    |> Plug.Conn.send_file(200, Path.expand("../../../priv/static/index.html", __DIR__))
  end
end
