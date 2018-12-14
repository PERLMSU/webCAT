defmodule WebCATWeb.IndexController do
  use WebCATWeb, :controller

  alias WebCAT.Repo
  import Ecto.Query

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do


    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)
    

    # Grab simple statistics
    counts = %{
      students: Repo.aggregate(from(s in "students"), :count, :id),
      observations: Repo.aggregate(from(o in "observations"), :count, :id),
      emails: Repo.aggregate(from(d in "drafts"), :count, :id),
      users: Repo.aggregate(from(u in "users"), :count, :id)
    }

    render(conn, "stats.html", user: user, counts: counts)
  end
end
