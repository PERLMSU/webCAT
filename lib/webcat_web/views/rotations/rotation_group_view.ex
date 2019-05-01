defmodule WebCATWeb.RotationGroupView do
  use WebCATWeb, :view

  alias WebCAT.Rotations.{RotationGroup, Rotation}

  def render("list.json", %{rotation_groups: groups}) do
    render_many(groups, __MODULE__, "group.json")
  end

  def render("show.json", %{rotation_group: group}) do
    render_one(group, __MODULE__, "group.json")
  end

  def render("group.json", %{rotation_group: %RotationGroup{} = group}) do
    group
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{rotation: %Rotation{} = rotation} = map ->
        Map.put(
          map,
          :rotation,
          render_one(rotation, WebCATWeb.RotationView, "rotation.json")
        )

      map ->
        Map.delete(map, :rotation)
    end
    |> case do
      %{users: users} = map when is_list(users) ->
        Map.put(map, :users, render_many(users, WebCATWeb.UserView, "user.json"))

      map ->
        Map.delete(map, :users)
    end
  end
end
