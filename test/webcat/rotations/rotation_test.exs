defmodule WebCAT.Feedback.RotationTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Rotation

  describe "changeset/2" do
    test "behaves as expected" do
      assert Rotation.changeset(%Rotation{}, Factory.params_with_assocs(:rotation)).valid?
    end
  end
end
