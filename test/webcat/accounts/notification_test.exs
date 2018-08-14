defmodule WebCAT.Accounts.NotificationTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Accounts.Notification
  alias WebCAT.Factory

  describe "changeset/2" do
    test "behaves as expected" do
      assert Notification.changeset(%Notification{}, Factory.params_with_assocs(:notification)).valid?
    end
  end
end
