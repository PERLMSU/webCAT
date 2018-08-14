defmodule WebCATWeb.RotationGroupView do
  @moduledoc """
  Render rotation groups
  """

  use WebCATWeb, :view

  alias WebCAT.Rotations.RotationGroup

  def render("list.json", %{rotation_groups: rotation_groups}) do
    render_many(rotation_groups, __MODULE__, "notification.json")
  end

  def render("show.json", %{rotation_group: rotation_group}) do
    render_one(rotation_group, __MODULE__, "rotation_group.json")
  end

  def render("rotation_group.json", %{rotation_group: %RotationGroup{} = rotation_group}) do
    rotation_group
    |> Map.from_struct()
  end
end
