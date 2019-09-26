defmodule WebCATWeb.DraftViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.DraftView

  describe "render/2" do
    test "it renders a group draft properly", %{conn: conn} do
      draft = Factory.insert(:group_draft)
      rendered = DraftView.show(draft, conn, %{})[:data]
      attributes = rendered[:attributes]

      assert rendered[:id] == to_string(draft.id)
      assert attributes[:content] == draft.content
      assert attributes[:notes] == draft.notes
      assert attributes[:status] == draft.status
      assert attributes[:student_id] == draft.student_id
      assert attributes[:rotation_group_id] == draft.rotation_group_id
    end

    test "it renders a list of group drafts properly", %{conn: conn} do
      drafts = Factory.insert_list(3, :group_draft)
      rendered_list = DraftView.index(drafts, conn, %{})
      assert Enum.count(rendered_list) == 3
    end

    test "it renders a student draft properly", %{conn: conn} do
      draft = Factory.insert(:student_draft)
      rendered = DraftView.show(draft, conn, %{})[:data]
      attributes = rendered[:attributes]

      assert rendered[:id] == to_string(draft.id)
      assert attributes[:content] == draft.content
      assert attributes[:notes] == draft.notes
      assert attributes[:status] == draft.status
      assert attributes[:student_id] == draft.student_id
      assert attributes[:rotation_group_id] == draft.rotation_group_id
    end

    test "it renders a list of student drafts properly", %{conn: conn} do
      drafts = Factory.insert_list(3, :student_draft)
      rendered_list = DraftView.index(drafts, conn, %{})
      assert Enum.count(rendered_list) == 3
    end

  end
end
