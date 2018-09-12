defmodule WebCAT.Feedback.EmailTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Email

  describe "changeset/2" do
    test "behaves as expected" do
      assert Email.changeset(%Email{}, Factory.params_with_assocs(:email)).valid?
    end
  end
end
