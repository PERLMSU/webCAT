defmodule WebCATWeb.IndexController do
  use WebCATWeb, :controller

  alias WebCAT.Repo
  alias WebCATWeb.Import
  import Ecto.Query
  alias WebCat
  alias WebCAT.Accounts.Users

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    student_count = Users.with_role("student") |> Enum.count()

    # Grab simple statistics
    counts = %{
      students: student_count,
      observations: Repo.aggregate(from(o in "observations"), :count, :id),
      emails: Repo.aggregate(from(d in "drafts"), :count, :id),
      users: Repo.aggregate(from(u in "users"), :count, :id) - student_count
    }

    render(conn, "overview.html", user: user, counts: counts, selected: "overview")
  end

  def redirect_index(conn, _params) do
    redirect(conn, to: Routes.index_path(conn, :index))
  end

  def import(conn, _params) do
    user = Auth.current_resource(conn)

    render(conn, "import.html", user: user, selected: "import")
  end

  def do_import(conn, assigns) do
    Auth.current_resource(conn)

    case assigns do
      %{"import" => %{"file" => %{path: path}}} ->
        case Import.from_path(path) do
          :ok ->
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
