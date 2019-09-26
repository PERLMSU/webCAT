defmodule WebCATWeb.ExplanationViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.ExplanationView

  describe "render/2" do
    test "it renders a explanation item properly", %{conn: conn} do
      explanation = Factory.insert(:explanation)
      rendered = ExplanationView.show(explanation, conn, %{})[:data]

      assert rendered[:id] == to_string(explanation.id)
      assert rendered[:attributes][:content] == explanation.content
      assert rendered[:attributes][:feedback_id] == explanation.feedback_id
    end

    test "it renders a list of explanation items properly", %{conn: conn} do
      explanations = Factory.insert_list(3, :explanation)
      rendered_list = ExplanationView.index(explanations, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
