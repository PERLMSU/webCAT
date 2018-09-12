defmodule WebCAT.Feedback.ObservationTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Observation

  describe "changeset/2" do
    test "behaves as expected" do
      assert Observation.changeset(%Observation{}, Factory.params_with_assocs(:observation)).valid?
    end
  end
end
