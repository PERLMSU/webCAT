defmodule WebCAT.Feedback.CommentTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Comment

  describe "changeset/2" do
    test "behaves as expected" do
      changeset = Comment.changeset(%Comment{}, Factory.params_with_assocs(:comment))

      assert changeset.valid?
    end
  end
end
