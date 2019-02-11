defmodule WebCAT.Rotations.StudentsTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Students

  test "rotation_groups/2 behaves as expected" do
    Factory.insert_list(5, :rotation_group)
    inserted = Factory.insert(:student, rotation_groups: Factory.insert_list(4, :rotation_group))

    rotation_groups = Students.rotation_groups(inserted.id, limit: 2, offset: 1)
    assert Enum.count(rotation_groups) == 2
  end
end
