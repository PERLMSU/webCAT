defmodule WebCAT.Accounts.PasswordResetTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.PasswordReset

  describe "changeset/2" do
    test "behaves as expected" do
      assert PasswordReset.changeset(
               %PasswordReset{},
               Factory.params_with_assocs(:password_reset)
             ).valid?
    end
  end
end
