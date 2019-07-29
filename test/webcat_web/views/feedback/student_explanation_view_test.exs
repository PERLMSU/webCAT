defmodule WebCATWeb.StudentExplanationViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.StudentExplanationView

  describe "render/2" do
    test "it renders a student explanation item properly" do
      student_explanation = Factory.insert(:student_explanation)

      rendered =
        StudentExplanationView.render("show.json", student_explanation: student_explanation)

      assert rendered[:user_id] == student_explanation.user_id
      assert rendered[:rotation_group_id] == student_explanation.rotation_group_id
      assert rendered[:feedback_id] == student_explanation.feedback_id
      assert rendered[:explanation_id] == student_explanation.explanation_id
    end

    test "it renders a list of student explanation items properly" do
      student_explanations = Factory.insert_list(3, :student_explanation)

      rendered_list =
        StudentExplanationView.render("list.json", student_explanations: student_explanations)

      assert Enum.count(rendered_list) == 3
    end
  end
end
