defmodule WebCAT.Feedback.ExplanationTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Explanation

  describe "changeset/2" do
    test "behaves as expected" do
      assert Explanation.changeset(%Explanation{}, Factory.params_with_assocs(:explanation)).valid?
    end
  end
end
