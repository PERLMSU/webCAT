defmodule WebCATWeb.NotificationView do
  use WebCATWeb, :view

  alias WebCAT.Accounts.{Notification, User}
  alias WebCAT.Feedback.Draft

  alias WebCATWeb.{DraftView, UserView}

  def render("list.json", %{notifications: notifications}) do
    render_many(notifications, __MODULE__, "notification.json")
  end

  def render("show.json", %{notification: notification}) do
    render_one(notification, __MODULE__, "notification.json")
  end

  def render("notification.json", %{notification: %Notification{} = notification}) do
    notification
    |> Map.from_struct()
    |> Map.drop(~w(__meta__)a)
    |> timestamps_format()
    |> case do
      %{draft: %Draft{} = draft} = map ->
        Map.put(
          map,
          :draft,
          render_one(draft, DraftView, "draft.json")
        )

      map ->
        Map.delete(map, :draft)
    end
    |> case do
      %{user: %User{} = user} = map ->
        Map.put(
          map,
          :user,
          render_one(user, UserView, "user.json")
        )

      map ->
        Map.delete(map, :user)
    end
  end
end
