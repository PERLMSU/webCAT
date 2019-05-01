defmodule WebCATWeb.StudentFeedbackViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.StudentFeedbackView

  describe "render/2" do
    test "it renders a student feedback item properly" do
      student_feedback = Factory.insert(:student_feedback)
      rendered = StudentFeedbackView.render("show.json", student_feedback: student_feedback)

      assert rendered[:user_id] == student_feedback.user_id
      assert rendered[:rotation_group_id] == student_feedback.rotation_group_id
      assert rendered[:feedback_id] == student_feedback.feedback_id
    end

    test "it renders a list of student feedback items properly" do
      student_feedback = Factory.insert_list(3, :student_feedback)
      rendered_list = StudentFeedbackView.render("list.json", student_feedback: student_feedback)
      assert Enum.count(rendered_list) == 3
    end
  end
end
