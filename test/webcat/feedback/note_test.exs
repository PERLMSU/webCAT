defmodule WebCAT.Feedback.NoteTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Note

  test "changeset/2 behaves as expected" do
    assert Note.changeset(%Note{}, Factory.params_with_assocs(:student_note)).valid?
    assert Note.changeset(%Note{}, Factory.params_with_assocs(:observation_note)).valid?
    assert Note.changeset(%Note{}, Factory.params_with_assocs(:misc_note)).valid?
  end
end
