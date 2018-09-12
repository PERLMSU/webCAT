defmodule WebCAT.Rotations.Semesters do
  @moduledoc """
  Helper functions for working with semesters
  """

  alias WebCAT.Repo
  alias WebCAT.Rotations.Classroom

  import Ecto.Query

  def classrooms(semester_id, options \\ []) do
    Classroom
    |> where([c], c.semester_id == ^semester_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end
end
