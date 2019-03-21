defmodule WebCAT.Feedback.GradeTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Grade

  test "changeset/2 behaves as expected" do
    assert Grade.changeset(%Grade{}, Factory.params_with_assocs(:grade)).valid?
  end
end
