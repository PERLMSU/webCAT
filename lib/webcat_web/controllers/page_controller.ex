defmodule WebCATWeb.PageController do
  use WebCATWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
