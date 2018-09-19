defmodule WebCAT.Rotations.SemestersTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Semesters

  describe "classrooms/2" do
    test "behaves as expected" do
      inserted = Factory.insert(:semester)
      Factory.insert_list(5, :classroom, semester: inserted)

      classrooms = Semesters.classrooms(inserted.id, limit: 2, offset: 1)
      assert Enum.count(classrooms) == 2
    end
  end
end
