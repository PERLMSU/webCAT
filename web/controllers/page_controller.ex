defmodule WebCAT.PageController do
  use WebCAT.Web, :controller

  def index(conn, _assigns) do
    render(conn, "index.html")
  end
end
