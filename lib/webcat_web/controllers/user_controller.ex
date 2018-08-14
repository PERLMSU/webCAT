defmodule WebCATWeb.UserController do
  @moduledoc """
  Handle authentication tasks
  """

  use WebCATWeb, :controller

  alias WebCAT.Accounts.Users
  alias WebCATWeb.UserView

  action_fallback(InTheDoor.Web.FallbackController)

  def index(conn, params) do
    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, users} <- Users.list(limit: limit, offset: offset) do
      conn
      |> render(UserView, "list.json", users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    with {:ok, user} <- Users.get(id) do
      conn
      |> render(UserView, "show.json", user: user)
    end
  end

  def update(conn, %{"id" => id} = params) do
    # TODO: Authenticate user updates much better, this is a blatant rush job
    with {:ok, updated} <- Users.update(id, Map.drop(params, ["id"])) do
      conn
      |> render(UserView, "show.json", user: updated)
    end
  end

  def notifications(conn, %{"id" => id} = params) do
    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, notifications} <- Users.notifications(id, limit: limit, offset: offset) do
      conn
      |> render(NotificationView, "list.json", notifications: notifications)
    end
  end

  def notifications(conn, %{"id" => id} = params) do
    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, notifications} <- Users.notifications(id, limit: limit, offset: offset) do
      conn
      |> render(NotificationView, "list.json", notifications: notifications)
    end
  end

  def classrooms(conn, %{"id" => id} = params) do
    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, classrooms} <- Users.classrooms(id, limit: limit, offset: offset) do
      conn
      |> render(ClassroomView, "list.json", classrooms: classrooms)
    end
  end

  def rotation_groups(conn, %{"id" => id} = params) do
    limit = Map.get(params, "limit", 25)
    offset = Map.get(params, "offset", 0)

    with {:ok, groups} <- Users.rotation_groups(id, limit: limit, offset: offset) do
      conn
      |> render(RotationGroupView, "list.json", rotation_groups: groups)
    end
  end
end
