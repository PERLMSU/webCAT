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

      assert PasswordCredential.changeset(cred, %{
               "current_password" => "password",
               "new_password" => "password1",
               "confirm_new_password" => "password1"
             }).valid?

      refute PasswordCredential.changeset(cred, %{
               "current_password" => "password2",
               "new_password" => "password1",
               "confirm_new_password" => "password1"
             }).valid?

      refute PasswordCredential.changeset(cred, %{
               "current_password" => "password",
               "new_password" => "password1",
               "confirm_new_password" => "password12"
             }).valid?

      refute PasswordCredential.changeset(cred, %{
               "current_password" => "password123",
               "new_password" => "password1",
               "confirm_new_password" => "password12"
             }).valid?
    end
  end
end
