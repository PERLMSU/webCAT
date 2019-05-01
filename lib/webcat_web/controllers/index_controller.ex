defmodule WebCATWeb.IndexController do
  use WebCATWeb, :controller

  alias WebCat

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
