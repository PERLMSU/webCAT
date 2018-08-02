defmodule WebCAT.Accounts.PasswordResetTest do
  use WebCAT.ModelCase, async: true

  alias WebCAT.Accounts.PasswordReset
  alias WebCAT.Factory

  describe "changeset/2" do
    test "behaves as expected" do
      assert PasswordReset.changeset(%PasswordReset{}, Factory.params_with_assocs(:password_reset)).valid?
    end

    test "honors unique constraints" do
      reset = Factory.insert(:password_reset)

      {:error, _} =
        Repo.insert(PasswordReset.changeset(%PasswordReset{}, Map.from_struct(reset)))
    end
  end
end
