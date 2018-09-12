defmodule WebCAT.Feedback.CategoriesTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Categories

  describe "list/2" do
    test "behaves as expected" do
      Factory.insert_list(12, :category)

      categories = Categories.list(limit: 6, offset: 10)
      assert Enum.count(categories) == 2
    end
  end

  describe "show/1" do
    test "behaves as expected" do
      inserted = Factory.insert(:category)

      {:ok, category} = Categories.get(inserted.id)
      assert category.name == inserted.name

      {:error, :not_found} = Categories.get(123_456)
    end
  end

  describe "create/1" do
    test "behaves as expected" do
      params = Factory.params_for(:category)

      {:ok, category} = Categories.create(params)
      assert category.name == params.name
    end
  end

  describe "update/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:category)
      params = Factory.params_for(:category)

      {:ok, category} = Categories.update(inserted.id, params)
      assert category.id == inserted.id
      assert category.name == params.name
      assert category.description == params.description
    end
  end

  describe "delete/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:category)

      {:ok, _} = Categories.delete(inserted.id)
      {:error, :not_found} = Categories.get(inserted.id)
    end
  end

  describe "observations/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:category)
      Factory.insert_list(5, :observation, category: inserted)

      observations = Categories.observations(inserted.id, limit: 2, offset: 1)
      assert Enum.count(observations) == 2
    end
  end
end
