defmodule WebCATWeb.IndexView do
  use WebCATWeb, :view

  def dashboard_menu(conn, selected), do: WebCATWeb.Dashboard.View.dashboard_menu(conn, selected)
end
