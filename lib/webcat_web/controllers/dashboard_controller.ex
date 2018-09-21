defmodule WebCATWeb.DashboardController do
  @moduledoc """
  Render the main
  """

  use WebCATWeb, :controller

  def index(conn, assigns) do
    render(conn, "dashboard.html")
  end
end

