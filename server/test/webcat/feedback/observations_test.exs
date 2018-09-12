defmodule WebCAT.Feedback.ObservationsTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Observations

  describe "notes/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:observation)
      Factory.insert_list(5, :observation_note, observation: inserted)

      notes = Observations.notes(inserted.id, limit: 2, offset: 1)
      assert Enum.count(notes) == 2
    end
  end

  describe "explanations/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:observation)
      Factory.insert_list(5, :explanation, observation: inserted)

      explanations = Observations.explanations(inserted.id, limit: 2, offset: 1)
      assert Enum.count(explanations) == 2
    end
  end
end
