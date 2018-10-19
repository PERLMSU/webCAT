defmodule WebCAT.Feedback.EmailTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Feedback.Email

  test "changeset/2 behaves as expected" do
    assert Email.changeset(%Email{}, Factory.params_with_assocs(:email)).valid?
  end
end
