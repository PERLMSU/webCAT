defmodule WebCATWeb.DashboardController do
  @moduledoc """
  Render the main
  """

  use WebCATWeb, :controller

  action_fallback(WebCATWeb.FallbackController)

  alias WebCAT.Rotations.{Semester, Classroom}
  alias WebCAT.CRUD

  def index(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(WebCAT.Rotations, :list_semesters, user) do
      render(conn, "index.html", user: user)
    end
  end

  def import_export(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    render(conn, "import_export.html", user: user)
  end
end
