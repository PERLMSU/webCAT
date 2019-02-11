defmodule WebCAT.Rotations.Students do
  import Ecto.Query
  alias WebCAT.Rotation.Student
  alias WebCAT.Repo

  def list(section_id) when is_binary(section_id) or is_integer(section_id) do
    Student
    |> join(:left, [s], sec in assoc(s, :sections))
    |> where([_, s], s.id == ^section_id)
    |> join(:left, [s], u in assoc(s, :user))
    |> preload([_, _, u], user: u)
    |> Repo.all()
  end
end
