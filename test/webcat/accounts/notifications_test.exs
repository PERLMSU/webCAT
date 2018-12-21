defmodule WebCAT.Accounts.NotificationsTest do
  use WebCAT.DataCase, async: true

  alias WebCAT.Repo
  alias WebCAT.Accounts.{Notification, Notifications}

  test "mark_seen/1 works as expected" do
    notification = Factory.insert(:notification)
    other_notification = Factory.insert(:notification)

    assert not notification.seen
    {:ok} = Notifications.mark_seen(notification)
    notification = Repo.get(Notification, notification.id)
    assert notification.seen

    assert not other_notification.seen
    {:ok} = Notifications.mark_seen(other_notification.id)
    other_notification = Repo.get(Notification, other_notification.id)
    assert other_notification.seen
  end

  test "create/3 works as expected" do
    draft = Factory.insert(:draft)
    user = Factory.insert(:user)

    {:ok, notification} = Notifications.create("Test", draft.id, user.id)

    assert not notification.seen
    assert notification.content == "Test"
    assert notification.draft_id == draft.id
    assert notification.user_id == user.id

    {:error, _} = Notifications.create("Test", 999, 999)
  end
end
