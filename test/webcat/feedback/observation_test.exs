defmodule WebCAT.Feedback.ObservationTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Observation

  test "changeset/2 behaves as expected" do
    assert Observation.changeset(%Observation{}, Factory.params_with_assocs(:observation)).valid?
  end
end
