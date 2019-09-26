defmodule WebCATWeb.CategoryViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.CategoryView

  describe "render/2" do
    test "it renders a category properly", %{conn: conn} do
      category = Factory.insert(:category)
      rendered = CategoryView.show(category, conn, %{})[:data]

      assert rendered[:id] == to_string(category.id)
      assert rendered[:attributes][:name] == category.name
      assert rendered[:attributes][:description] == category.description
      assert rendered[:attributes][:parent_category_id] == category.parent_category_id
    end

    test "it renders a list of categories properly", %{conn: conn} do
      categories = Factory.insert_list(3, :category)
      rendered_list = CategoryView.index(categories, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
