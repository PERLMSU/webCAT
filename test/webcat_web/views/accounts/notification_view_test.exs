defmodule WebCATWeb.NotificationViewTest do
  use WebCATWeb.ConnCase

  alias WebCATWeb.NotificationView

  describe "render/2" do
    test "it renders a notification properly", %{conn: conn} do
      notification = Factory.insert(:notification)
      rendered = NotificationView.show(notification, conn, %{})[:data]

      assert rendered[:id] == to_string(notification.id)
      assert rendered[:attributes][:seen] == notification.seen
      assert rendered[:attributes][:draft_id] == notification.draft_id
      assert rendered[:attributes][:user_id] == notification.user_id
    end

    test "it renders a list of notifications properly", %{conn: conn} do
      notifications = Factory.insert_list(3, :notification)
      rendered_list = NotificationView.index(notifications, conn, %{})
      assert Enum.count(rendered_list) == 3
    end
  end
end
