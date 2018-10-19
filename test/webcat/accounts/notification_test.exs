defmodule WebCAT.Accounts.NotificationTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.Notification

  test "changeset/2 behaves as expected" do
    assert Notification.changeset(%Notification{}, Factory.params_with_assocs(:notification)).valid?
  end
end
