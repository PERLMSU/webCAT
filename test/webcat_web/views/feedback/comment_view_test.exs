defmodule WebCATWeb.CommentViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.CommentView

  describe "render/2" do
    test "it renders a comment properly", %{conn: conn} do
      comment = Factory.insert(:comment)
      rendered = CommentView.show(comment, conn, %{})[:data]

      assert rendered[:id] == to_string(comment.id)
      assert rendered[:attributes][:content] == comment.content
      assert rendered[:attributes][:draft_id] == comment.draft_id
      assert rendered[:attributes][:user_id] == comment.user_id
    end

    test "it renders a list of comments properly", %{conn: conn} do
      comments = Factory.insert_list(3, :comment)
      rendered_list = CommentView.index(comments, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
