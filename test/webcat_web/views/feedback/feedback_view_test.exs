defmodule WebCATWeb.FeedbackViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.FeedbackView

  describe "render/2" do
    test "it renders a feedback item properly" do
      feedback = Factory.insert(:feedback)
      rendered = FeedbackView.render("show.json", feedback: feedback)

      assert rendered[:id] == feedback.id
      assert rendered[:content] == feedback.content
      assert rendered[:observation_id] == feedback.observation_id
    end

    test "it renders a list of feedback items properly" do
      feedback = Factory.insert_list(3, :feedback)
      rendered_list = FeedbackView.render("list.json", feedback: feedback)
      assert Enum.count(rendered_list) == 3
    end
  end
end
