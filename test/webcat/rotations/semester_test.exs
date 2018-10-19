defmodule WebCAT.Feedback.SemesterTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Semester

  test "changeset/2 behaves as expected" do
    assert Semester.changeset(%Semester{}, Factory.params_with_assocs(:semester)).valid?
  end
end
