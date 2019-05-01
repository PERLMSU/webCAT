defmodule WebCATWeb.CommentViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.CommentView

  describe "render/2" do
    test "it renders a comment properly" do
      comment = Factory.insert(:comment)
      rendered = CommentView.render("show.json", comment: comment)

      assert rendered[:id] == comment.id
      assert rendered[:content] == comment.content
      assert rendered[:draft_id] == comment.draft_id
      assert rendered[:user_id] == comment.user_id
    end

    test "it renders a list of comments properly" do
      comments = Factory.insert_list(3, :comment)
      rendered_list = CommentView.render("list.json", comments: comments)
      assert Enum.count(rendered_list) == 3
    end
  end
end
