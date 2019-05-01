defmodule WebCATWeb.DraftViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.DraftView

  describe "render/2" do
    test "it renders a draft properly" do
      draft = Factory.insert(:draft)
      rendered = DraftView.render("show.json", draft: draft)

      assert rendered[:id] == draft.id
      assert rendered[:content] == draft.content
      assert rendered[:status] == draft.status
      assert rendered[:user_id] == draft.user_id
      assert rendered[:rotation_group_id] == draft.rotation_group_id
    end

    test "it renders a list of drafts properly" do
      drafts = Factory.insert_list(3, :draft)
      rendered_list = DraftView.render("list.json", drafts: drafts)
      assert Enum.count(rendered_list) == 3
    end
  end
end
