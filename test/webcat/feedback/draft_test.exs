defmodule WebCAT.Feedback.DraftTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Draft

  test "changeset/2 behaves as expected" do
    assert Draft.changeset(%Draft{}, Factory.params_with_assocs(:draft)).valid?
  end
end
