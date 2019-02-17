defmodule WebCATWeb.Feedback.StudentFeedback do
  import Ecto.Query
  alias WebCAT.Repo
  alias WebCAT.Feedback.Feedback
  alias WebCAT.Rotations.{Student, RotationGroup}

  @doc """
  List all feedback items for a student in a particular rotation group
  """
  def list(rotation_group_id, student_id) do
    "student_feedback"
    |> where([sf], sf.rotation_group_id == ^rotation_group_id and sf.student_id == ^student_id)
    |> join(:left, [sf], f in Feedback, on: sf.feedback_id == f.id)
    |> select([_, f], f)
    |> Repo.all()
  end

  @doc """
  Add a feedback item to a student in a rotation group
  """
  def add(rotation_group_id, student_id, feedback_id) do
  end

  @doc """
  Remove a feedback item from a student in a rotation group
  """
  def delete(rotation_group_id, student_id, feedback_id) do
  end
end
