defmodule WebCAT.Rotations.RotationGroupsTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.RotationGroups

  test "drafts/2 behaves as expected" do
    inserted = Factory.insert(:rotation_group)
    Factory.insert_list(5, :draft, rotation_group: inserted)

    drafts = RotationGroups.drafts(inserted.id, limit: 2, offset: 1)
    assert Enum.count(drafts) == 2
  end

  test "students/2 behaves as expected" do
    Factory.insert_list(5, :student)
    inserted = Factory.insert(:rotation_group, students: Factory.insert_list(4, :student))

    students = RotationGroups.students(inserted.id, limit: 2, offset: 1)
    assert Enum.count(students) == 2
  end
end
