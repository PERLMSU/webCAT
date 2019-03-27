defmodule WebCATWeb.IndexController do
  use WebCATWeb, :authenticated_controller

  alias WebCAT.Repo
  alias WebCATWeb.Import
  import Ecto.Query
  alias WebCat
  alias WebCAT.Accounts.Users

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, _params) do
    student_count = from(u in Users.by_role(User, "student"), group_by: u.id, select: count(u.id))

    # Grab simple statistics
    counts = %{
      students: student_count,
      observations: Repo.aggregate(from(o in "observations"), :count, :id),
      emails: Repo.aggregate(from(d in "drafts"), :count, :id),
      users: Repo.aggregate(from(u in "users"), :count, :id) - student_count
    }

    render(conn, "overview.html", user: user, counts: counts, selected: "overview")
  end

  def redirect_index(conn, _user, _params) do
    redirect(conn, to: Routes.index_path(conn, :index))
  end

  def changes(conn, user, _params) do
    render(conn, "changes.html", user: user, selected: nil)
  end

  def import(conn, user, _params) do
    render(conn, "import.html", user: user, selected: "import")
  end

  def do_import(conn, _user, params) do
    case params do
      %{"import" => %{"file" => %{path: path}}} ->
        case Import.from_path(path) do
          {:ok, _} ->
            conn
            |> put_flash(:info, "Import successful")
            |> redirect(to: Routes.index_path(conn, :import))

          {:error, message} ->
            conn
            |> put_flash(:error, "Import failed: #{message}")
            |> redirect(to: Routes.index_path(conn, :import))
        end

      _ ->
        conn
        |> put_flash(:error, "Import failed: please select a file")
        |> redirect(to: Routes.index_path(conn, :import))
    end
  end
end
