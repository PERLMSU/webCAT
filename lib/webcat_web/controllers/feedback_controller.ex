defmodule WebCATWeb.FeedbackController do
  @moduledoc """
  Logic for working with the feedback writer
  """

  use WebCATWeb, :controller

  alias WebCAT.Rotations.{RotationGroup, Rotation}

  alias Timex.Interval

  alias WebCAT.Repo
  import Ecto.Query

  action_fallback(WebCATWeb.FallbackController)

  def index(conn, _params) do
    user = WebCATWeb.Auth.Guardian.Plug.current_resource(conn)

    with :ok <- Bodyguard.permit(RotationGroup, :list, user),
         :ok <- Bodyguard.permit(Rotation, :list, user) do
      rotation_groups =
        RotationGroup
        |> where([rotation_group], rotation_group.instructor_id == ^user.id)
        |> join(:inner, [rotation_group], rotation in "rotations",
          on: rotation.id == rotation_group.rotation_id
        )
        |> order_by([_, rotation], rotation.number)
        |> preload([_, rotation], rotation: rotation)
        |> Repo.all()

      # Find the current rotation group based on which interval the current time is included in
      current_rotation_group =
        Enum.find(rotation_groups, fn rotation_group ->
          Timex.now() in Interval.new(
            from: rotation_group.rotation.start_date,
            until: rotation_group.rotation.end_date
          )
        end)

      assigns =
        []
        |> Keyword.put(:conn, conn)
        |> Keyword.put(:user, user)
        |> Keyword.put(:rotation_groups, rotation_groups)
        |> Keyword.put(:current_rotation_group, current_rotation_group)

      render(conn, "index.html", assigns)
    end
  end
end
