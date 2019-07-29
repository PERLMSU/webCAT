defmodule WebCATWeb.Channels.NotificationChannelTest do
  use WebCATWeb.ChannelCase, async: true

  test "Notification broadcasts work as expected" do
    user = Factory.insert(:user)
    {:ok, token, _claims} = Auth.encode_and_sign(user)
    notification = Factory.string_params_with_assocs(:notification)

    {:ok, socket} = connect(WebCATWeb.UserSocket, %{"token" => token}, %{})

    {:ok, _, socket} =
      subscribe_and_join(socket, WebCATWeb.NotificationsChannel, "notifications:#{user.id}", %{})

    broadcast_from(socket, "notifications:#{user.id}", notification)
    channel_name = "notifications:#{user.id}"
    assert_push ^channel_name, ^notification
  end
end
