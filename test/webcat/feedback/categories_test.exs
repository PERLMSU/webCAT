defmodule WebCAT.Feedback.CategoriesTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Categories

  test "observations/2 behaves as expected" do
    inserted = Factory.insert(:category)
    Factory.insert_list(5, :observation, category: inserted)

    observations = Categories.observations(inserted.id, limit: 2, offset: 1)
    assert Enum.count(observations) == 2
  end
end
