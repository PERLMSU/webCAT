defmodule WebCATWeb.FeedbackViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.FeedbackView

  describe "render/2" do
    test "it renders a feedback item properly", %{conn: conn} do
      feedback = Factory.insert(:feedback)
      rendered = FeedbackView.show(feedback, conn, %{})[:data]

      assert rendered[:id] == to_string(feedback.id)
      assert rendered[:attributes][:content] == feedback.content
      assert rendered[:attributes][:observation_id] == feedback.observation_id
    end

    test "it renders a list of feedback items properly", %{conn: conn} do
      feedback = Factory.insert_list(3, :feedback)
      rendered_list = FeedbackView.index(feedback, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
