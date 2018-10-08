defmodule WebCATWeb.RotationGroupsController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    render(conn, "rotation_groups.html")
  end
end

