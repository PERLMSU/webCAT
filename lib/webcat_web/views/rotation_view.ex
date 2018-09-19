defmodule WebCATWeb.RotationView do
  @moduledoc """
  Render rotations
  """

  use WebCATWeb, :view

  alias WebCAT.Rotations.Rotation

  def render("list.json", %{rotations: rotations}) do
    render_many(rotations, __MODULE__, "rotation.json")
  end

  def render("show.json", %{rotation: rotation}) do
    render_one(rotation, __MODULE__, "rotation.json")
  end

  def render("rotation.json", %{rotation: %Rotation{} = rotation}) do
    rotation
    |> Map.from_struct()
    |> Map.take(~w(id start_date end_date classroom_id inserted_at updated_at)a)
  end
end
