defmodule WebCAT.Feedback.DraftTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Draft

  describe "changeset/2" do
    test "behaves as expected" do
      assert Draft.changeset(%Draft{}, Factory.params_with_assocs(:draft)).valid?
    end
  end
end
