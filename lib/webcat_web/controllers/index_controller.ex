defmodule WebCATWeb.IndexController do
  use WebCATWeb, :authenticated_controller

  alias WebCAT.Repo
  alias WebCATWeb.Import
  import Ecto.Query
  alias WebCat
  alias WebCAT.Accounts.Users
  alias WebCAT.Rotations.{Classroom, Classrooms}
  alias WebCAT.Feedback.{Observations, Drafts}

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, user, params) do
    permissions do
      has_role(:admin)
      has_role(:assistant)
    end

    with :ok <- is_authorized?() do
      classroom = Users.get_classroom(user, params)
      active_rotation = Classrooms.get_active_rotation(classroom)

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
        classroom: classroom,
        active_rotation: active_rotation,
        chart_data: %{
          observations: Observations.observations_per_student(classroom),
          drafts: Drafts.draft_status_breakdown(active_rotation),
          weekly_draft_progress: Drafts.weekly_draft_progress(active_rotation)
        }
      )
    end
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
