defmodule WebCATWeb.InboxController do
  use WebCATWeb, :controller

  alias WebCAT.Repo
  import Ecto.Query

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    render(conn, "index.html", user: user, selected: "inbox")
  end
end
