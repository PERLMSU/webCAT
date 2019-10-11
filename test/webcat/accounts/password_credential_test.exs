defmodule WebCAT.Accounts.PasswordCredentialTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.PasswordCredential

  describe "changeset/2" do
    test "behaves as expected" do
      assert PasswordCredential.changeset(
               %PasswordCredential{},
               Factory.params_with_assocs(:password_credential)
             ).valid?
    end

    test "handles password changes appropriately" do
      cred = Factory.insert(:password_credential)
      changeset = PasswordCredential.changeset(cred, %{"password" => "password"})
      assert changeset.valid?
      assert changeset.changes.password != "password"
    end
  end
end
