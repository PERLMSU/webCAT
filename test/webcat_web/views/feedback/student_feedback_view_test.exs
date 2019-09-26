defmodule WebCATWeb.StudentFeedbackViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.StudentFeedbackView

  describe "render/2" do
    test "it renders a student explanation item properly", %{conn: conn} do
      student_feedback = Factory.insert(:student_feedback)

      rendered =
        StudentFeedbackView.show(student_feedback, conn, %{})[:data][:attributes]

      assert rendered[:draft_id] == student_feedback.draft_id
      assert rendered[:feedback_id] == student_feedback.feedback_id
    end

    test "it renders a list of student explanation items properly", %{conn: conn} do
      student_feedback = Factory.insert_list(3, :student_feedback)

      rendered_list =
        StudentFeedbackView.index(student_feedback, conn, %{})

      assert Enum.count(rendered_list) == 3
    end
  end
end
