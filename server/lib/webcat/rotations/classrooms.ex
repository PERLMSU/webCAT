defmodule WebCAT.Rotations.Classrooms do
  @moduledoc """
  Utility functions for working with classrooms
  """

  alias WebCAT.Repo
  alias WebCAT.Rotations.Classroom

  import Ecto.Query

  @doc """
  List classrooms in the system
  """
  @spec list(Keyword.t()) :: [Classroom.t()]
  def list(options \\ []) do
      Classroom
      |> limit(^Keyword.get(options, :limit, 25))
      |> offset(^Keyword.get(options, :offset, 0))
      |> Repo.all()
  end
end
