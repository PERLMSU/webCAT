defmodule WebCAT.Accounts.ConfirmationsTest do
  @moduledoc false

  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.Confirmations

  test "get/1 behaves as expected" do
    inserted = Factory.insert(:confirmation)

    {:ok, confirmation} = Confirmations.get(inserted.token)
    refute confirmation.verified
    assert confirmation.id == inserted.id
    assert confirmation.user_id == inserted.user_id
  end

  test "confirm/1 behaves as expected" do
    inserted = Factory.insert(:confirmation)

    {:ok, confirmation} = Confirmations.confirm(inserted.token)
    assert confirmation.verified
    assert confirmation.id == inserted.id
    assert confirmation.user_id == inserted.user_id
  end
end
