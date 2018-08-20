defmodule WebCAT.Accounts.ConfirmationTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.Confirmation
  alias WebCAT.Factory

  describe "changeset/2" do
    test "behaves as expected" do
      assert Confirmation.changeset(%Confirmation{}, Factory.params_with_assocs(:confirmation)).valid?
    end

    test "honors unique constraints" do
      confirmation = Factory.insert(:confirmation)

      {:error, _} =
        Repo.insert(Confirmation.changeset(%Confirmation{}, Map.from_struct(confirmation)))
    end
  end
end
