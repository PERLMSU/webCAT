defmodule WebCAT.Rotations.Students do
  @moduledoc """
  Helper functions for working with students
  """

  alias WebCAT.Repo
  alias WebCAT.Feedback.{Note, Draft}
  alias WebCAT.Rotations.RotationGroup

  import Ecto.Query

  def drafts(student_id, options \\ []) do
    Draft
    |> where([d], d.student_id == ^student_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def notes(student_id, options \\ []) do
    Note
    |> where([n], n.student_id == ^student_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by(desc: :inserted_at)
    |> Repo.all()
  end

  def rotation_groups(student_id, options \\ []) do
    RotationGroup
    |> join(:inner, [rg], sg in "student_groups", sg.rotation_group_id == rg.id)
    |> where([_, sg], sg.student_id == ^student_id)
    |> limit(^Keyword.get(options, :limit, 25))
    |> offset(^Keyword.get(options, :offset, 0))
    |> order_by([rg, _], desc: rg.inserted_at)
    |> select([rg, _], rg)
    |> Repo.all()
  end
end
