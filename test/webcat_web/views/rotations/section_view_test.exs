defmodule WebCATWeb.SectionViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.SectionView

  describe "render/2" do
    test "it renders a section properly" do
      section = Factory.insert(:section)
      rendered = SectionView.render("show.json", section: section)

      assert rendered[:id] == section.id
      assert rendered[:number] == section.number
      assert rendered[:description] == section.description
      assert rendered[:semester_id] == section.semester_id
    end

    test "it renders a list of sections properly" do
      sections = Factory.insert_list(3, :section)
      rendered_list = SectionView.render("list.json", sections: sections)
      assert Enum.count(rendered_list) == 3
    end
  end
end
