defmodule WebCAT.Feedback.StudentTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Student

  describe "changeset/2" do
    test "behaves as expected" do
      assert Student.changeset(%Student{}, Factory.params_with_assocs(:student)).valid?
    end
  end
end
