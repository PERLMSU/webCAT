defmodule WebCAT.CRUDTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.CRUD
  alias WebCAT.Feedback.Category

  describe "list/2" do
    test "behaves as expected" do
      Factory.insert_list(12, :category)

      categories = CRUD.list(Category, limit: 6, offset: 10)
      assert Enum.count(categories) == 2
    end
  end

  describe "get/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:category)

      {:ok, category} = CRUD.get(Category, inserted.id)
      assert category.name == inserted.name

      {:error, :not_found} = CRUD.get(Category, 123_456)
    end
  end

  describe "create/2" do
    test "behaves as expected" do
      params = Factory.params_for(:category)

      {:ok, category} = CRUD.create(Category, params)
      assert category.name == params.name
    end
  end

  describe "update/3" do
    test "behaves as expected" do
      inserted = Factory.insert(:category)
      params = Factory.params_for(:category)

      {:ok, category} = CRUD.update(Category, inserted.id, params)
      assert category.id == inserted.id
      assert category.name == params.name
      assert category.description == params.description
    end
  end

  describe "delete/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:category)

      {:ok, _} = CRUD.delete(Category, inserted.id)
      {:error, :not_found} = CRUD.get(Category, inserted.id)
    end
  end
end
