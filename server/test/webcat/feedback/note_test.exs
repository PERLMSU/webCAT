defmodule WebCAT.Feedback.NoteTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Note

  describe "changeset/2" do
    test "behaves as expected" do
      assert Note.changeset(%Note{}, Factory.params_with_assocs(:student_note)).valid?
      assert Note.changeset(%Note{}, Factory.params_with_assocs(:observation_note)).valid?
      assert Note.changeset(%Note{}, Factory.params_with_assocs(:rotation_group_note)).valid?
    end
  end
end
