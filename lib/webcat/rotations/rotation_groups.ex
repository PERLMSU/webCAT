defmodule WebCAT.Rotations.RotationGroups do
  @moduledoc """
  Helper functions for working with rotation groups
  """

  alias WebCAT.Repo
  alias WebCAT.Feedback.Draft
  alias WebCAT.Rotations.Student

  import Ecto.Query

  def students(rotation_group_id, options \\ []) do
    Student
    |> join(:inner, [s], sg in "student_groups", sg.student_id == s.id)
    |> where([_, sg], sg.rotation_group_id == ^rotation_group_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by([s, _], desc: s.inserted_at)
    |> select([s, _], s)
    |> Repo.all()
  end
end
