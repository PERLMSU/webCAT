defmodule WebCATWeb.ExplanationViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.ExplanationView

  describe "render/2" do
    test "it renders a explanation item properly" do
      explanation = Factory.insert(:explanation)
      rendered = ExplanationView.render("show.json", explanation: explanation)

      assert rendered[:id] == explanation.id
      assert rendered[:content] == explanation.content
      assert rendered[:feedback_id] == explanation.feedback_id
    end

    test "it renders a list of explanation items properly" do
      explanations = Factory.insert_list(3, :explanation)
      rendered_list = ExplanationView.render("list.json", explanations: explanations)
      assert Enum.count(rendered_list) == 3
    end
  end
end
