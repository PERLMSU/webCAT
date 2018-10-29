defmodule WebCATWeb.RotationGroupsController do
  @moduledoc """
  """

  use WebCATWeb, :controller

  action_fallback(WebCATWeb.FallbackController)

  alias WebCAT.CRUD
  alias WebCAT.Rotations.RotationGroup

  def index(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with rotation_groups <- CRUD.list(RotationGroup) do
      render(conn, "index.html", rotation_groups: rotation_groups, user: user)
    end
  end
end
