defmodule WebCAT.Feedback.CategoryTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Category

  describe "changeset/2" do
    test "behaves as expected" do
      assert Category.changeset(%Category{}, Factory.params_with_assocs(:category)).valid?
    end

    test "honors unique constraints" do
      category = Factory.insert(:category)

      {:error, _} =
        Repo.insert(Category.changeset(%Category{}, Map.from_struct(category)))
    end
  end
end
