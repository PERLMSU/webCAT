defmodule WebCATWeb.NotificationViewTest do
  use WebCAT.DataCase

  alias WebCATWeb.NotificationView

  describe "render/2" do
    test "it renders a notification properly" do
      notification = Factory.insert(:notification)
      rendered = NotificationView.render("show.json", notification: notification)

      assert rendered[:id] == notification.id
      assert rendered[:seen] == notification.seen
      assert rendered[:draft_id] == notification.draft_id
      assert rendered[:user_id] == notification.user_id
    end

    test "it renders a list of notifications properly" do
      notifications = Factory.insert_list(3, :notification)
      rendered_list = NotificationView.render("list.json", notifications: notifications)
      assert Enum.count(rendered_list) == 3
    end
  end
end
