defmodule WebCATWeb.RotationGroupsView do
  use WebCATWeb, :view


    @doc """
  Format a rotation group
  """
  def clean_rotation_group(rotation_group) do
    rotation_group
    |> Map.from_struct()
  end
end
