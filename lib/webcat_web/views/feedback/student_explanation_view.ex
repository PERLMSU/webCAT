defmodule WebCATWeb.StudentExplanationView do
  use WebCATWeb, :view

  alias WebCAT.Feedback.{StudentExplanation, Feedback, Explanation}
  alias WebCAT.Rotations.RotationGroup
  alias WebCAT.Accounts.User
  alias WebCATWeb.{UserView, RotationGroupView, FeedbackView, ExplanationView}

  def render("list.json", %{student_explanations: student_explanations}) do
    render_many(student_explanations, __MODULE__, "student_explanation.json")
  end

  def render("show.json", %{student_explanation: student_explanation}) do
    render_one(student_explanation, __MODULE__, "student_explanation.json")
  end

  def render("student_explanation.json", %{
        student_explanation: %StudentExplanation{} = student_explanation
      }) do
    student_explanation
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
    |> case do
      %{explanation: %Explanation{} = explanation} = map ->
        Map.put(map, :explanation, render_one(explanation, ExplanationView, "explanation.json"))

      map ->
        Map.delete(map, :explanation)
    end
  end
end
