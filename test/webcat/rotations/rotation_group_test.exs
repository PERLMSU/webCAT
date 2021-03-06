defmodule WebCAT.Feedback.RotationGroupTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.RotationGroup

  test "changeset/2 behaves as expected" do
    assert RotationGroup.changeset(%RotationGroup{}, Factory.params_with_assocs(:rotation_group)).valid?
  end
end
