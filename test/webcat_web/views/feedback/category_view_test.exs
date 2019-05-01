defmodule WebCATWeb.CategoryViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.CategoryView

  describe "render/2" do
    test "it renders a category properly" do
      category = Factory.insert(:category)
      rendered = CategoryView.render("show.json", category: category)

      assert rendered[:id] == category.id
      assert rendered[:name] == category.name
      assert rendered[:description] == category.description
      assert rendered[:parent_category_id] == category.parent_category_id
    end

    test "it renders a list of categories properly" do
      categories = Factory.insert_list(3, :category)
      rendered_list = CategoryView.render("list.json", categories: categories)
      assert Enum.count(rendered_list) == 3
    end
  end
end
