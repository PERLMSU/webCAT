defmodule WebCATWeb.NotificationsChannel do
  use WebCATWeb, :channel

  def join("notifications:" <> user_id, payload, socket) do
    if authorized?(user_id, socket) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("notifications:seen:" <> user_id, %{"notification_id" => id}, socket) do
    case Notification.seen(id) do
      :ok -> {:noreply, socket}
      :error -> {:reply, {:error, %{error: "problem marking notification as seen"}}, socket}
    end
  end

  def handle_in(_, _, socket) do
    {:reply, {:error, %{reason: "channel does not exist"}}, socket}
  end

  def join(_, _, _) do
    {:error, %{reason: "channel does not exist"}}
  end

  defp authorized?(user_id, socket) do
    to_string(socket.assigns.current_user.id) == user_id
  end
end
