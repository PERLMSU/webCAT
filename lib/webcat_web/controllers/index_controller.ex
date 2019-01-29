defmodule WebCATWeb.IndexController do
  use WebCATWeb, :controller

  alias WebCAT.Repo
  import Ecto.Query

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    # Grab simple statistics
    counts = %{
      students: Repo.aggregate(from(s in "students"), :count, :id),
      observations: Repo.aggregate(from(o in "observations"), :count, :id),
      emails: Repo.aggregate(from(d in "drafts"), :count, :id),
      users: Repo.aggregate(from(u in "users"), :count, :id)
    }

    render(conn, "overview.html", user: user, counts: counts, selected: "overview")
  end

  def redirect_index(conn, _params) do
    redirect(conn, to: Routes.index_path(conn, :index))
  end
end
