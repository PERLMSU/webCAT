defmodule WebCAT.Feedback.FeedbackTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Feedback

  test "changeset/2 behaves as expected" do
    assert Feedback.changeset(%Feedback{}, Factory.params_with_assocs(:feedback)).valid?
  end
end
