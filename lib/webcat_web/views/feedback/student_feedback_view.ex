defmodule WebCATWeb.StudentFeedbackView do
  use WebCATWeb, :view

  alias WebCAT.Feedback.{StudentFeedback, Feedback}
  alias WebCAT.Rotations.RotationGroup
  alias WebCAT.Accounts.User
  alias WebCATWeb.{UserView, RotationGroupView, FeedbackView}

  def render("list.json", %{student_feedback: student_feedback}) do
    render_many(student_feedback, __MODULE__, "student_feedback.json")
  end

  def render("show.json", %{student_feedback: student_feedback}) do
    render_one(student_feedback, __MODULE__, "student_feedback.json")
  end

  def render("student_feedback.json", %{student_feedback: %StudentFeedback{} = student_feedback}) do
    student_feedback
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{student: %User{} = student} = map ->
        Map.put(map, :student, render_one(student, UserView, "user.json"))

      map ->
        Map.delete(map, :student)
    end
    |> case do
      %{rotation_group: %RotationGroup{} = group} = map ->
        Map.put(map, :rotation_group, render_one(group, RotationGroupView, "group.json"))

      map ->
        Map.delete(map, :rotation_group)
    end
    |> case do
      %{feedback: %Feedback{} = feedback} = map ->
        Map.put(map, :feedback, render_one(feedback, FeedbackView, "feedback.json"))

      map ->
        Map.delete(map, :feedback)
    end
  end
end
