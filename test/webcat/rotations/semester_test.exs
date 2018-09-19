defmodule WebCAT.Feedback.SemesterTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Semester

  describe "changeset/2" do
    test "behaves as expected" do
      assert Semester.changeset(%Semester{}, Factory.params_with_assocs(:semester)).valid?
    end
  end
end
