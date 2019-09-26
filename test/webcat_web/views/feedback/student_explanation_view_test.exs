defmodule WebCATWeb.StudentExplanationViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.StudentExplanationView

  describe "render/2" do
    test "it renders a student explanation item properly", %{conn: conn} do
      student_explanation = Factory.insert(:student_explanation)

      rendered =
        StudentExplanationView.show(student_explanation, conn, %{})[:data][:attributes]

      assert rendered[:draft_id] == student_explanation.draft_id
      assert rendered[:feedback_id] == student_explanation.feedback_id
      assert rendered[:explanation_id] == student_explanation.explanation_id
    end

    test "it renders a list of student explanation items properly", %{conn: conn} do
      student_explanations = Factory.insert_list(3, :student_explanation)

      rendered_list =
        StudentExplanationView.index(student_explanations, conn, %{})

      assert Enum.count(rendered_list) == 3
    end
  end
end
