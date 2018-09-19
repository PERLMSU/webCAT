defmodule WebCAT.Accounts.ConfirmationsTest do
  @moduledoc false

  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.Confirmations

  describe "get/1" do
    test "behaves as expected" do
      inserted = Factory.insert(:confirmation)

      {:ok, confirmation} = Confirmations.get(inserted.token)
      refute confirmation.verified
      assert confirmation.id == inserted.id
      assert confirmation.user_id == inserted.user_id
    end
  end

  describe "confirm/1" do
    test "behaves as expected" do
      inserted = Factory.insert(:confirmation)

      {:ok, confirmation} = Confirmations.confirm(inserted.token)
      assert confirmation.verified
      assert confirmation.id == inserted.id
      assert confirmation.user_id == inserted.user_id
    end
  end
end
