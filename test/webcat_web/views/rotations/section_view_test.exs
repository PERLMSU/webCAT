defmodule WebCATWeb.SectionViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.SectionView

  describe "render/2" do
    test "it renders a section properly", %{conn: conn} do
      section = Factory.insert(:section)
      rendered = SectionView.show(section, conn, %{})[:data]
      
      assert rendered[:id] == to_string(section.id)
      assert rendered[:attributes][:number] == section.number
      assert rendered[:attributes][:description] == section.description
      assert rendered[:attributes][:semester_id] == section.semester_id
    end

    test "it renders a list of sections properly", %{conn: conn} do
      sections = Factory.insert_list(3, :section)
      rendered_list = SectionView.index(sections, conn, %{})

      assert Enum.count(rendered_list) == 3
    end
  end
end
