defmodule WebCAT.Feedback.StudentTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Rotations.Student

    test "changeset/2 behaves as expected" do
      assert Student.changeset(%Student{}, Factory.params_with_assocs(:student)).valid?
    end
  end
