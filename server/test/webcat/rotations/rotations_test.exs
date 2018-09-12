defmodule WebCAT.Rotations.RotationsTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Rotations

  describe "rotation_groups/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:rotation)
      Factory.insert_list(5, :rotation_group, rotation: inserted)

      rotation_groups = Rotations.rotation_groups(inserted.id, limit: 2, offset: 1)
      assert Enum.count(rotation_groups) == 2
    end
  end
end
