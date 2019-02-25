defmodule WebCAT.Feedback.RotationTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Rotation

  test "changeset/2 behaves as expected" do
    assert Rotation.changeset(%Rotation{}, Factory.params_with_assocs(:rotation)).valid?
  end
end
