defmodule WebCATWeb.FeedbackController do
  @moduledoc """
  Logic for working with the feedback writer
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users
  alias WebCAT.Rotations.RotationGroup
  alias WebCAT.CRUD

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = Auth.current_resource(conn)

    rotation_groups = Users.rotation_groups(user)

    render(conn, "index.html", user: user, selected: "feedback", rotation_groups: rotation_groups)
  end

  def show(conn, %{"rotation_group_id" => id}) do
    user = Auth.current_resource(conn)

    with {:ok, rotation_group} <- CRUD.get(RotationGroup, id) do

      render(conn, "show.html", user: user, selected: "feedback", rotation_group: rotation_group)
    end
  end
end
