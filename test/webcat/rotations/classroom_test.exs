defmodule WebCAT.Feedback.ClassroomTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Classroom

  test "changeset/2 behaves as expected" do
    assert Classroom.changeset(%Classroom{}, Factory.params_with_assocs(:classroom)).valid?
  end
end
