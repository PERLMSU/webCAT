defmodule WebCATWeb.IndexController do
  use WebCATWeb, :controller

  alias WebCat

  action_fallback(WebCATWeb.FallbackController)

  def redirect_index(conn, _params) do
    redirect(conn, to: Routes.index_path(conn, :index, []))
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
