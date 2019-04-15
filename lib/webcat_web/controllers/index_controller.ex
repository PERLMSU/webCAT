defmodule WebCATWeb.IndexController do
  use WebCATWeb, :authenticated_controller

  alias WebCAT.Repo
  alias WebCATWeb.Import
  import Ecto.Query
  alias WebCat
  alias WebCAT.Accounts.Users

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, _params) do
    # Grab simple statistics
    counts = %{
      students:
        Repo.aggregate(
          Users.with_role("student"),
          :count,
          :id
        ),
      observations: Repo.one(from(o in "student_feedback", select: fragment("count(*)"))),
      emails: Repo.aggregate(from(d in "drafts", where: d.status == "emailed"), :count, :id)
    }

    render(conn, "overview.html",
      user: user,
      counts: counts,
      selected: "overview",
      chart_data: %{
        observations:
          Jason.encode!([["Mar 6", 2.2], ["Mar 13", 4.5], ["Mar 20", 3.4], ["Mar 27", 5.5]]),
        drafts: Jason.encode!([["Approved", 50], ["Reviewing", 20], ["Unreviewed", 70]])
      }
    )
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
