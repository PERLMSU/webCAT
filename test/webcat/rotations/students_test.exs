defmodule WebCAT.Rotations.StudentsTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Students

  test "drafts/2 behaves as expected" do
    inserted = Factory.insert(:student)
    Factory.insert_list(5, :draft, student: inserted)

    drafts = Students.drafts(inserted.id, limit: 2, offset: 1)
    assert Enum.count(drafts) == 2
  end

  test "notes/2 behaves as expected" do
    inserted = Factory.insert(:student)
    Factory.insert_list(5, :student_note, student: inserted)

    notes = Students.notes(inserted.id, limit: 2, offset: 1)
    assert Enum.count(notes) == 2
  end

  test "rotation_groups/2 behaves as expected" do
    Factory.insert_list(5, :rotation_group)
    inserted = Factory.insert(:student, rotation_groups: Factory.insert_list(4, :rotation_group))

    rotation_groups = Students.rotation_groups(inserted.id, limit: 2, offset: 1)
    assert Enum.count(rotation_groups) == 2
  end
end
