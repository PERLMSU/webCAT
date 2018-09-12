defmodule WebCAT.Rotations.Rotations do
  @moduledoc """
  Helper functions for working with rotations
  """

  alias WebCAT.Repo
  alias WebCAT.Rotations.RotationGroup

  import Ecto.Query

  def rotation_groups(rotation_id, options \\ []) do
    RotationGroup
    |> where([rg], rg.rotation_id == ^rotation_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
